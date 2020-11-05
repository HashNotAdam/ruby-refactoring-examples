# frozen_string_literal: true

# formerly: Introduce Explaining Variables
# inverse of: Inline Variable
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/extractfunction.html

# Goal: Add a name to an expression

module FirstSetOfRefactorings
  module ExtractVariable
    module InAClass
      class BeforeRefactor < RefactorBase
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
          base_price - [0, quantity - 500].max * item_price *
            0.05 + [base_price * 0.1, 100.0].min
        end
      end

      class Refactor1 < RefactorBase
        attr_accessor :quantity
        attr_accessor :item_price

        def initialize(base_price, quantity, item_price)
          super()

          @base_price = base_price
          @quantity = quantity
          @item_price = item_price
        end

        def price
          base_price - quantity_discount + shipping
        end

        def base_price
          quantity * item_price
        end

        def quantity_discount
          [0, quantity - 500].max * item_price * 0.05
        end

        def shipping
          [base_price * 0.1, 100.0].min
        end
      end

      class Tests
        def self.call
          new.call
        end

        INVOICE = OpenStruct.new(
          customer: "Adam",
          due_date: nil,
          orders: [
            OpenStruct.new(amount: 1),
            OpenStruct.new(amount: 2),
          ]
        ).freeze

        def call
          BeforeRefactor.new(INVOICE.dup).price
          Refactor1.new(INVOICE.dup).price
          Refactor2.new(INVOICE.dup).price
        end
      end
    end
  end
end
