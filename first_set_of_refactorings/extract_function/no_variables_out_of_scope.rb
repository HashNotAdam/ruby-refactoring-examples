# frozen_string_literal: true

require "ostruct"

# Example: No Variables Out of Scope
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/extractfunction.html

# Goal: extract single responsibilities into their own functions

module FirstSetOfRefactorings
  module ExtractFunction
    module NoVariablesOutOfScope
      class BeforeRefactor < RefactorBase
        attr_accessor :invoice
        attr_accessor :outstanding

        def initialize(invoice)
          super()

          @invoice = invoice
          @outstanding = 0
        end

        def print_owing
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"

          # calculate outstanding
          invoice.orders.each do |order|
            self.outstanding += order.amount
          end

          # record due date
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days

          # print details
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
        end
      end

      ##
      # Extract the "Customer Owes" banner
      ##
      class Refactor1 < RefactorBase
        attr_accessor :invoice
        attr_accessor :outstanding

        def initialize(invoice)
          super()

          @invoice = invoice
          @outstanding = 0
        end

        def print_owing
          print_banner

          # calculate outstanding
          invoice.orders.each do |order|
            self.outstanding += order.amount
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
      class Refactor2 < RefactorBase
        attr_accessor :invoice
        attr_accessor :outstanding

        def initialize(invoice)
          super()

          @invoice = invoice
          @outstanding = 0
        end

        def print_owing
          print_banner

          # calculate outstanding
          invoice.orders.each do |order|
            self.outstanding += order.amount
          end

          # record due date
          thirty_days = 30 * 60 * 60 * 24
          invoice.due_date = Time.now + thirty_days

          print_details
        end

        def print_banner
          puts "***********************"
          puts "**** Customer Owes ****"
          puts "***********************"
        end

        def print_details
          puts "name: #{invoice.customer}"
          puts "amount: #{outstanding}"
          puts "due: #{invoice.due_date.strftime("%F")}"
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
          BeforeRefactor.new(INVOICE.dup).print_owing
          Refactor1.new(INVOICE.dup).print_owing
          Refactor2.new(INVOICE.dup).print_owing
        end
      end
    end
  end
end
