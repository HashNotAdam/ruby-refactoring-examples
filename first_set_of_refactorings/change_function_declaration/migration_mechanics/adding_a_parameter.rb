# frozen_string_literal: true

require "ostruct"

##
#      aka:	Rename Function
# formerly:	Rename Method
# formerly:	Add Parameter
# formerly:	Remove Parameter
#      aka:	Change Signature
##

# Example: Adding a parameter
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/changefunctiondeclaration.html

##
# Goal: Add a new (required) parameter to a method
##

module FirstSetOfRefactorings
  module ChangeFunctionDeclaration
    module MigrationMechanics
      module AddingAParameter
        class BeforeRefactor < RefactorBase
          attr_reader :reservations

          def initialize
            super()
            @reservations = []
          end

          def add_reservation(customer)
            @reservations << customer
          end
        end

        ##
        # Use Extract Function to create a new method with a temporary name
        ##
        class Refactor1 < RefactorBase
          attr_reader :reservations

          def initialize
            super()
            @reservations = []
          end

          def add_reservation(customer)
            zz_add_reservation(customer)
          end

          def zz_add_reservation(customer)
            @reservations << customer
          end
        end

        ##
        # Add the parameter to the new declaration and its call
        ##
        class Refactor2 < RefactorBase
          attr_reader :reservations

          def initialize
            super()
            @reservations = []
          end

          def add_reservation(customer)
            zz_add_reservation(customer, false)
          end

          def zz_add_reservation(customer, _is_priority)
            @reservations << customer
          end
        end

        ##
        # Test that callers are using the new parameter
        ##
        class Refactor3 < RefactorBase
          attr_reader :reservations

          def initialize
            super()
            @reservations = []
          end

          def add_reservation(customer, is_priority = nil)
            assert(!is_priority.nil?)

            is_priority ||= false
            zz_add_reservation(customer, is_priority)
          end

          def zz_add_reservation(customer, _is_priority)
            @reservations << customer
          end
        end

        ##
        # When all the callers are using the correct parameters, use Inline
        # Function
        ##
        class Refactor4 < RefactorBase
          attr_reader :reservations

          def initialize
            super()
            @reservations = []
          end

          def add_reservation(customer, _is_priority)
            @reservations << customer
          end
        end

        class Tests
          CUSTOMER = OpenStruct.new(name: "Adam")

          def call
            [BeforeRefactor, Refactor1, Refactor2, Refactor3].each do |klass|
              instance = klass.new
              instance.add_reservation(CUSTOMER)
              puts "Reservations: #{instance.reservations}"
            end

            instance = Refactor4.new
            instance.add_reservation(CUSTOMER, false)
            puts "Reservations: #{instance.reservations}"
          end
        end
      end
    end
  end
end
