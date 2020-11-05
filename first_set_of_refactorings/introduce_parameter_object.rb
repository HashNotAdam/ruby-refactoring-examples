# frozen_string_literal: true

require "ostruct"

# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/introduceparameterobject.html

# Goal: combine data items that travel together into a single value object

# This example doesn't translate well into Ruby since Ruby already has a concept
# of a range object, however, this doesn't take away from the value of the point
# of the example
module FirstSetOfRefactorings
  module IntroduceParameterObject
    STATION = {
      name: "ZB1",
      readings: [
        { temp: 47, time: "2016-11-10 09:10" },
        { temp: 53, time: "2016-11-10 09:20" },
        { temp: 58, time: "2016-11-10 09:30" },
        { temp: 53, time: "2016-11-10 09:40" },
        { temp: 51, time: "2016-11-10 09:50" },
      ],
    }.freeze

    OPERATING_PLAN = OpenStruct.new(
      temperature_floor: 48,
      temperature_ceiling: 57
    ).freeze

    class BeforeRefactor < RefactorBase
      # Passing 2 parameters from OPERATING_PLAN which use different labels
      # to those of readings_outside_range
      def alerts
        readings_outside_range(
          FirstSetOfRefactorings::IntroduceParameterObject::STATION,
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling
        )
      end

      def readings_outside_range(station, min, max)
        station[:readings].select do |reading|
          reading[:temp] < min || reading[:temp] > max
        end
      end
    end

    ##
    # Create a value object that represents the values
    ##
    class NumberRange
      attr_reader :min
      attr_reader :max

      def initialize(min, max)
        @min = min
        @max = max
      end
    end

    ##
    # Use Change Function Declaration to add the new object as a parameter
    ##
    class Refactor1 < RefactorBase
      def alerts
        readings_outside_range(
          FirstSetOfRefactorings::IntroduceParameterObject::STATION,
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling,
          nil
        )
      end

      # At this point, behavior hasn't changed and tests should still pass
      def readings_outside_range(station, min, max, range)
        station[:readings].select do |reading|
          reading[:temp] < min || reading[:temp] > max
        end
      end
    end

    ##
    # Go to each caller and adjust it to pass in the correct date range
    # (behaviour still hasn't changed)
    ##
    class Refactor2 < RefactorBase
      def alerts
        range = NumberRange.new(
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling
        )
        readings_outside_range(
          FirstSetOfRefactorings::IntroduceParameterObject::STATION,
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling,
          range
        )
      end

      # At this point, behavior hasn't changed and tests should still pass
      def readings_outside_range(station, min, max, range)
        station[:readings].select do |reading|
          reading[:temp] < min || reading[:temp] > max
        end
      end
    end

    ##
    # Start replacing the parameters (we'll begin by replacing max)
    ##
    class Refactor3 < RefactorBase
      def alerts
        range = NumberRange.new(
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling
        )
        readings_outside_range(
          FirstSetOfRefactorings::IntroduceParameterObject::STATION,
          OPERATING_PLAN.temperature_floor,
          range
        )
      end

      def readings_outside_range(station, min, range)
        station[:readings].select do |reading|
          reading[:temp] < min || reading[:temp] > range.max
        end
      end
    end

    ##
    # Remove the remaining parameter (min)
    ##
    class Refactor4 < RefactorBase
      def alerts
        range = NumberRange.new(
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling
        )
        readings_outside_range(
          FirstSetOfRefactorings::IntroduceParameterObject::STATION,
          range
        )
      end

      def readings_outside_range(station, range)
        station[:readings].select do |reading|
          reading[:temp] < range.min || reading[:temp] > range.max
        end
      end
    end

    ##
    # Now it is possible to move functionality into the value object. For
    # example, the value object can decide if a value is in range.
    ##
    class NumberRange
      def include?(value)
        value >= min && value <= max
      end
    end

    class Refactor5 < RefactorBase
      def alerts
        range = NumberRange.new(
          OPERATING_PLAN.temperature_floor,
          OPERATING_PLAN.temperature_ceiling
        )
        readings_outside_range(
          FirstSetOfRefactorings::IntroduceParameterObject::STATION,
          range
        )
      end

      def readings_outside_range(station, range)
        station[:readings].reject { |reading| range.include?(reading[:temp]) }
      end
    end

    class Tests
      def call
        puts (BeforeRefactor.new.alerts == expectation).to_s
        puts (Refactor1.new.alerts == expectation).to_s
        puts (Refactor2.new.alerts == expectation).to_s
        puts (Refactor3.new.alerts == expectation).to_s
        puts (Refactor4.new.alerts == expectation).to_s
        puts (Refactor5.new.alerts == expectation).to_s
      end

      private

      def expectation
        [
          { temp: 47, time: "2016-11-10 09:10" },
          { temp: 58, time: "2016-11-10 09:30" },
        ]
      end
    end
  end
end
