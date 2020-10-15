# frozen_string_literal: true

require "ostruct"

# Example: Using local variables
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/extractfunction.html

# Goal: extract single responsibilities into their own functions

module FirstSetOfRefactorings
  module ExtractFunction
    module UsingLocalVariables
      class BeforeRefactor < RefactorBase
        def print_owing(invoice)
          outstanding = 0

          print_banner

          # calculate outstanding
          invoice.orders.each do |order|
            outstanding += order.amount
          end

          # record due date
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days

          # print details
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end
      end

      ##
      # Extract the printing of order details
      ##
      class Refactor1 < RefactorBase
        def print_owing(invoice)
          outstanding = 0

          print_banner

          # calculate outstanding
          invoice.orders.each do |order|
            outstanding += order.amount
          end

          # record due date
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days

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
      end

      ##
      # Extract setting the invoice due date
      # Extract a function when modifying a structure (such as an array, record,
      # or object)
      ##
      class Refactor2 < RefactorBase
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
        end
      end
    end
  end
end
