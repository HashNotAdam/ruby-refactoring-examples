# frozen_string_literal: true

require "ostruct"

# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/splitphase.html

# Goal: Take code that's dealing with two different things and split it into
#       separate modules

module FirstSetOfRefactorings
  module SplitPhase
    class BeforeRefactor < RefactorBase
      # There is a sense of two phases going on here. The first couple of
      # lines of code use the product information to calculate the
      # product-oriented price of the order, while the later code uses
      # shipping information to determine the shipping cost. If there are
      # changes coming up that complicate the pricing and shipping
      # calculations, but they work relatively independently, then splitting
      # this code into two phases is valuable.
      def price_order(product, quantity, shipping_method)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        shipping_per_case =
          if base_price > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = quantity * shipping_per_case
        base_price - discount + shipping_cost
      end
    end

    ##
    # Apply Extract Function to the shipping calculation
    ##
    class Refactor1 < RefactorBase
      def price_order(product, quantity, shipping_method)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        apply_shipping(base_price, shipping_method, quantity, discount)
      end

      def apply_shipping(base_price, shipping_method, quantity, discount)
        shipping_per_case =
          if base_price > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = quantity * shipping_per_case
        base_price - discount + shipping_cost
      end
    end

    ##
    # Introduce the intermediate data structure that will communicate between
    # the two phases
    ##
    class Refactor2 < RefactorBase
      def price_order(product, quantity, shipping_method)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        price_data = {}
        apply_shipping(
          price_data, base_price, shipping_method, quantity, discount
        )
      end

      def apply_shipping(
        price_data, base_price, shipping_method, quantity, discount
      )
        shipping_per_case =
          if base_price > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = quantity * shipping_per_case
        base_price - discount + shipping_cost
      end
    end

    ##
    # Look at the various parameters to apply_shipping.
    # The first one is base_price which is created by the first-phase code.
    # Move this into the intermediate data structure, removing it from the
    # parameter list.
    ##
    class Refactor3 < RefactorBase
      def price_order(product, quantity, shipping_method)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        price_data = { base_price: base_price }
        apply_shipping(price_data, shipping_method, quantity, discount)
      end

      def apply_shipping(price_data, shipping_method, quantity, discount)
        shipping_per_case =
          if price_data[:base_price] > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = quantity * shipping_per_case
        price_data[:base_price] - discount + shipping_cost
      end
    end

    ##
    # The next parameter in the list is shipping_method. This isn't used by
    # the first-phase code so it remains untouched.
    #
    # quantity is used by the first phase so it is moved to the intermediate
    # data structure
    ##
    class Refactor4 < RefactorBase
      def price_order(product, quantity, shipping_method)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        price_data = { base_price: base_price, quantity: quantity }
        apply_shipping(price_data, shipping_method, discount)
      end

      def apply_shipping(price_data, shipping_method, discount)
        shipping_per_case =
          if price_data[:base_price] > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = price_data[:quantity] * shipping_per_case
        price_data[:base_price] - discount + shipping_cost
      end
    end

    ##
    # Finally, discount is moved to the intermediate data structure
    ##
    class Refactor5 < RefactorBase
      def price_order(product, quantity, shipping_method)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        price_data = {
          base_price: base_price, quantity: quantity, discount: discount,
        }
        apply_shipping(price_data, shipping_method)
      end

      def apply_shipping(price_data, shipping_method)
        shipping_per_case =
          if price_data[:base_price] > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = price_data[:quantity] * shipping_per_case
        price_data[:base_price] - price_data[:discount] + shipping_cost
      end
    end

    ##
    # Now the intermediate data structure is fully formed so the first-phase
    # code can be extracted into its own method
    ##
    class Refactor6 < RefactorBase
      def price_order(product, quantity, shipping_method)
        price_data = pricing_data(product, quantity)
        apply_shipping(price_data, shipping_method)
      end

      def pricing_data(product, quantity)
        base_price = product.base_price * quantity
        discount = [quantity - product.discount_threshold, 0].max *
          product.base_price * product.discount_rate
        { base_price: base_price, quantity: quantity, discount: discount }
      end

      def apply_shipping(price_data, shipping_method)
        shipping_per_case =
          if price_data[:base_price] > shipping_method.discount_threshold
            shipping_method.discounted_fee
          else
            shipping_method.fee_per_case
          end
        shipping_cost = price_data[:quantity] * shipping_per_case
        price_data[:base_price] - price_data[:discount] + shipping_cost
      end
    end

    class Tests
      PRODUCT = OpenStruct.new(
        base_price: 10,
        discount_threshold: 5,
        discount_rate: 0.9
      ).freeze

      SHIPPING_METHOD = OpenStruct.new(
        discount_threshold: 5,
        discounted_fee: 1,
        fee_per_case: 2
      ).freeze

      def call
        [
          BeforeRefactor, Refactor1, Refactor2, Refactor3, Refactor4,
          Refactor5, Refactor6,
        ].each do |klass|
          price = klass.new.price_order(
            PRODUCT, 15, SHIPPING_METHOD
          )
          puts (price == 75).to_s
        end
      end
    end
  end
end
