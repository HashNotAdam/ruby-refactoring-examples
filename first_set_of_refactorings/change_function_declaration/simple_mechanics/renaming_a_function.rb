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
# Consideration: A disadvantage of this simple way is that all the callers and
#                declaration changes must be done at once
##

module FirstSetOfRefactorings
  module ChangeFunctionDeclaration
    module SimpleMechanics
      module RenamingAFunction
        class BeforeRefactor < RefactorBase
          def circum(radius)
            2 * Math::PI * radius
          end
        end

        ##
        # Change the function name to something more clear then find all the
        # callers of circum and change the name to circumference
        ##
        class Refactor1 < RefactorBase
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
