# frozen_string_literal: true

require "ostruct"

# Example: Reassigning a local variable
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/extractfunction.html

# Goal: extract single responsibilities into their own functions

module FirstSetOfRefactorings
  module ExtractFunction
    module ReassigningALocalVariable
      class BeforeRefactor < RefactorBase
        def print_owing(invoice)
          outstanding = 0

          print_banner

          # calculate outstanding
          invoice.orders.each do |order|
            outstanding += order.amount
          end

          record_due_date(invoice)

          print_details(invoice, outstanding)
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def print_details(invoice, outstanding)
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def record_due_date(invoice)
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days
        end
      end

      ##
      # Slide the declaration (outstanding) next its use
      ##
      class Refactor1 < RefactorBase
        def print_owing(invoice)
          print_banner

          # calculate outstanding
          outstanding = 0
          invoice.orders.each do |order|
            outstanding += order.amount
          end

          record_due_date(invoice)

          print_details(invoice, outstanding)
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def print_details(invoice, outstanding)
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def record_due_date(invoice)
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days
        end
      end

      ##
      # Copy the code into a function (calculate_outstanding)
      # Do NOT remove the original code yet
      ##
      class Refactor2 < RefactorBase
        def print_owing(invoice)
          print_banner

          # calculate outstanding
          outstanding = 0
          invoice.orders.each do |order|
            outstanding += order.amount
          end

          record_due_date(invoice)

          print_details(invoice, outstanding)
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def calculate_outstanding(invoice)
          outstanding = 0
          invoice.orders.each do |order|
            outstanding += order.amount
          end
          outstanding
        end

        def print_details(invoice, outstanding)
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def record_due_date(invoice)
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days
        end
      end

      ##
      # Replace the original code with a call to the new function
      ##
      class Refactor3 < RefactorBase
        def print_owing(invoice)
          print_banner

          outstanding = calculate_outstanding(invoice)

          record_due_date(invoice)

          print_details(invoice, outstanding)
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def calculate_outstanding(invoice)
          outstanding = 0
          invoice.orders.each do |order|
            outstanding += order.amount
          end
          outstanding
        end

        def print_details(invoice, outstanding)
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def record_due_date(invoice)
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days
        end
      end

      ##
      # Rename the return value (optional)
      ##
      class Refactor4 < RefactorBase
        def print_owing(invoice)
          print_banner

          outstanding = calculate_outstanding(invoice)

          record_due_date(invoice)

          print_details(invoice, outstanding)
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def calculate_outstanding(invoice)
          result = 0
          invoice.orders.each do |order|
            result += order.amount
          end
          result
        end

        def print_details(invoice, outstanding)
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def record_due_date(invoice)
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days
        end
      end

      ##
      # Personal addition: be more ruby-like
      ##
      class Refactor5 < RefactorBase
        def print_owing(invoice)
          print_banner

          outstanding = calculate_outstanding(invoice)

          record_due_date(invoice)

          print_details(invoice, outstanding)
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def calculate_outstanding(invoice)
          (invoice.orders).inject(0) do |result, order|
            result + order.amount
          end
        end

        def print_details(invoice, outstanding)
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def record_due_date(invoice)
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days
        end
      end

      class Tests
        INVOICE = OpenStruct.new(
          customer: "Adam",
          due_date: nil,
          orders: [
            OpenStruct.new(amount: 1),
            OpenStruct.new(amount: 2),
          ]
        ).freeze

        def call
          BeforeRefactor.new.print_owing(INVOICE.dup)
          Refactor1.new.print_owing(INVOICE.dup)
          Refactor2.new.print_owing(INVOICE.dup)
          Refactor3.new.print_owing(INVOICE.dup)
          Refactor4.new.print_owing(INVOICE.dup)
          Refactor5.new.print_owing(INVOICE.dup)
        end
      end
    end
  end
end
