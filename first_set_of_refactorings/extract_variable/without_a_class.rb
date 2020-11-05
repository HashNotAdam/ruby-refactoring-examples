# frozen_string_literal: true

# formerly: Introduce Explaining Variables
# inverse of: Inline Variable
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/extractfunction.html

# Goal: Add a name to an expression

module FirstSetOfRefactorings
  module ExtractVariable
    module WithoutAClass
      class BeforeRefactor < RefactorBase
        def price(order)
          # price is base price - quantity discount + shipping
          order.quantity * order.item_price -
            [0, order.quantity - 500].max * order.item_price * 0.05 +
            [order.quantity * order.item_price * 0.1, 100.0].min
        end
      end

      class Refactor1 < RefactorBase
        def price(order)
          # price is base price - quantity discount + shipping
          base_price = order.quantity * order.item_price
          base_price - [0, order.quantity - 500].max *
            order.item_price * 0.05 + [base_price * 0.1, 100.0].min
        end
      end

      class Refactor2 < RefactorBase
        def price(order)
          # price is base price - quantity discount + shipping
          base_price = order.quantity * order.item_price
          quantity_discount = [0, order.quantity - 500].max *
            order.item_price * 0.05

          base_price - quantity_discount + [base_price * 0.1, 100.0].min
        end
      end

      class Refactor3 < RefactorBase
        def price(order)
          base_price = order.quantity * order.item_price
          quantity_discount = [0, order.quantity - 500].max * order.item_price * 0.05
          shipping = [order.quantity * order.item_price * 0.1, 100.0].min

          base_price - quantity_discount + shipping
        end
      end
    end
  end
end
