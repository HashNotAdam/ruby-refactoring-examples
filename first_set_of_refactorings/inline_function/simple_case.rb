# frozen_string_literal: true

require "ostruct"

# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/inlinefunction.html

# Goal: merge together multiple functions

module FirstSetOfRefactorings
  module InlineFunction
    module SimpleCase
      class BeforeRefactor < RefactorBase
        def rating(a_driver)
          more_than_five_late_deliveries(a_driver) ? 2 : 1
        end

        def more_than_five_late_deliveries(a_driver)
          a_driver.number_of_late_deliveries > 5
        end
      end

      ##
      # Since the variable names are the same, the
      # more_than_five_late_deliveries method can be inlined without
      # modification
      ##
      class Refactor1 < RefactorBase
        def rating(a_driver)
          a_driver.number_of_late_deliveries > 5 ? 2 : 1
        end
      end

      class Tests
        A_DRIVER = proc do |number_of_late_deliveries|
          OpenStruct.new(number_of_late_deliveries: number_of_late_deliveries).
            freeze
        end.freeze

        def call
          puts "Rating: #{BeforeRefactor.new.rating(A_DRIVER[5])}"
          puts "Rating: #{BeforeRefactor.new.rating(A_DRIVER[6])}"
          puts "Rating: #{Refactor1.new.rating(A_DRIVER[5])}"
          puts "Rating: #{Refactor1.new.rating(A_DRIVER[6])}"
        end
      end
    end
  end
end
