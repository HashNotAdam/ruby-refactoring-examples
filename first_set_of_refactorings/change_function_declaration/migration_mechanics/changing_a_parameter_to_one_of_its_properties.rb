# frozen_string_literal: true

require "ostruct"

##
#      aka:	Rename Function
# formerly:	Rename Method
# formerly:	Add Parameter
# formerly:	Remove Parameter
#      aka:	Change Signature
##

# Example: Changing a parameter to one of its properties
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/changefunctiondeclaration.html

##
# Goal: Take a method that utilises a value on an object and change to accept
#       the objectless value instead
##

module FirstSetOfRefactorings
  module ChangeFunctionDeclaration
    module MigrationMechanics
      module ChangingAParameterToOneOfItsProperties
        class BeforeRefactor < RefactorBase
          def in_new_england(a_customer)
            %w[MA CT ME VT NH RI].include?(a_customer.address.state)
          end
        end

        ##
        # Use Extract Function to create a new method
        ##
        class Refactor1 < RefactorBase
          def in_new_england(a_customer)
            state_code = a_customer.address.state
            xx_new_in_new_england(state_code)
          end

          def xx_new_in_new_england(state_code)
            %w[MA CT ME VT NH RI].include?(state_code)
          end
        end

        ##
        # Apply Inline Variable on the input parameter in the original function
        ##
        class Refactor2 < RefactorBase
          def in_new_england(a_customer)
            xx_new_in_new_england(a_customer.address.state)
          end

          def xx_new_in_new_england(state_code)
            %w[MA CT ME VT NH RI].include?(state_code)
          end
        end

        class Tests
          CUSTOMER = proc do |state|
            OpenStruct.new(
              address: OpenStruct.new(
                state: state
              )
            )
          end

          def call
            [BeforeRefactor, Refactor1, Refactor2].each do |klass|
              %w[AM MA].each do |state|
                case klass.new.in_new_england(CUSTOMER[state])
                when true
                  puts "#{state} is in New England"
                when false
                  puts "#{state} is not in New England"
                else
                  raise "Error testing #{klass} with #{state}"
                end
              end
            end
          end
        end
      end
    end
  end
end
