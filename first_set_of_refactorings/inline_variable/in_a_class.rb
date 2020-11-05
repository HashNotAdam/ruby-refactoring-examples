# frozen_string_literal: true

# formerly: Inline Temp
# inverse of: Extract Variable
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/extractfunction.html

# Goal: Remove a name from an expression

module FirstSetOfRefactorings
  module InlineVaiable
    module InAClass
      class BeforeRefactor < RefactorBase
        attr_accessor :quantity
        attr_accessor :item_price

        def initialize(quantity, item_price)
          super()

          @quantity = quantity
          @item_price = item_price
        end

        def price
          base_price - quantity_discount + shipping
        end

        def base_price
          @quantity * @item_price
        end

        def quantity_discount
          [0, @quantity - 500].max * @item_price * 0.05
        end

        def shipping
          [base_price * 0.1, 100.0].min
        end
      end

      class AfterRefactor < RefactorBase
        attr_accessor :base_price
        attr_accessor :quantity
        attr_accessor :item_price

        def initialize(quantity, item_price)
          super()

          @base_price = base_price
          @quantity = quantity
          @item_price = item_price
        end

        def price
          # price is base price - quantity discount + shipping
          base_price - [0, quantity - 500].max * item_price *
            0.05 + [base_price * 0.1, 100.0].min
        end
      end
    end
  end
end
