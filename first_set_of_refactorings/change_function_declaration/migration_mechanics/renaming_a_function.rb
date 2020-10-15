# frozen_string_literal: true

require "ostruct"

##
#      aka:	Rename Function
# formerly:	Rename Method
# formerly:	Add Parameter
# formerly:	Remove Parameter
#      aka:	Change Signature
##

# Example: Renaming a function
# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/changefunctiondeclaration.html

##
#    Motivation: A good name allows the reader to understand what the function
#                does without seeing the code that defines its implementation
#          Goal: Rename a function with a confusing name
# Consideration: While more time consuming, this method would allow you to stop
#                the refactor, mark the old method as deprecated, and only
#                remove the old method when it is certain that all references
#                have been changed
##

module FirstSetOfRefactorings
  module ChangeFunctionDeclaration
    module MigrationMechanics
      module RenamingAFunction
        class BeforeRefactor < RefactorBase
          def circum(radius)
            2 * Math::PI * radius
          end
        end

        ##
        # Create a new method with a more clear name
        ##
        class Refactor1 < RefactorBase
          def circum(radius)
            circumference(radius)
          end

          def circumference(radius)
            2 * Math::PI * radius
          end
        end

        ##
        # Test and then apply Inline Function
        ##
        class Refactor2 < RefactorBase
          def circumference(radius)
            2 * Math::PI * radius
          end
        end

        class Tests
          RADIUS = 10

          def call
            puts "Circumference: #{BeforeRefactor.new.circum(RADIUS)}"
            puts "Circumference: #{Refactor1.new.circumference(RADIUS)}"
          end
        end
      end
    end
  end
end
