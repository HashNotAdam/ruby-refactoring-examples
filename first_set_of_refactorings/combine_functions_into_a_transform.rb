# frozen_string_literal: true

require "ostruct"

# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/combinefunctionsintotransform.html

# Goal: similar to Combine Functions Into A Class, the aim is to take a group of
#       functions that work on a common body of data and combine them into a
#       single action. Transforms can be problematic in mutable languages where
#       the source data changes

module FirstSetOfRefactorings
  module CombineFunctionsIntoATransform
    READING = { customer: "ivan", quantity: 10, month: 5, year: 2017 }.freeze

    class BeforeRefactor < RefactorBase
      def client_1
        reading = READING
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def client_2
        reading = READING
        base = base_rate(reading[:month], reading[:year]) * reading[:quantity]
        [0, base - tax_threshold(reading[:year])].max
      end

      def client_3
        reading = READING
        base_charge(reading)
      end

      private

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end
    end

    ##
    # Move all of the derivations into a transformation step that takes the raw
    # reading and emits a reading enriched with all the common derived results
    ##
    class Refactor1 < RefactorBase
      def client_1
        reading = READING
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def client_2
        reading = READING
        base = base_rate(reading[:month], reading[:year]) * reading[:quantity]
        [0, base - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        base_charge(reading)
      end

      private

      def enrich_reading(reading)
        reading.dup
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end
    end

    ##
    # Use Move Function on base_charge to move it to the enrichment calculation
    ##
    class Refactor2 < RefactorBase
      def client_1
        reading = READING
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def client_2
        reading = READING
        base = base_rate(reading[:month], reading[:year]) * reading[:quantity]
        [0, base - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        base_charge(reading)
      end

      private

      def enrich_reading(reading)
        result = reading.dup
        result[:base_charge] = base_charge(result)
        result
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end
    end

    ##
    # Change the client that uses that method to use the enriched field instead
    ##
    class Refactor3 < RefactorBase
      def client_1
        reading = READING
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def client_2
        reading = READING
        base = base_rate(reading[:month], reading[:year]) * reading[:quantity]
        [0, base - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      private

      def enrich_reading(reading)
        result = reading.dup
        result[:base_charge] = base_charge(result)
        result
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Update client 1 to use the enriched reading
    ##
    class Refactor4 < RefactorBase
      def client_1
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      def client_2
        reading = READING
        base = base_rate(reading[:month], reading[:year]) * reading[:quantity]
        [0, base - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      private

      def enrich_reading(reading)
        result = reading.dup
        result[:base_charge] = base_charge(result)
        result
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Update client 2 to use the enriched reading
    ##
    class Refactor5 < RefactorBase
      def client_1
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      def client_2
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        [0, reading[:base_charge] - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      private

      def enrich_reading(reading)
        result = reading.dup
        result[:base_charge] = base_charge(result)
        result
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Move the tax computation to enriched reading
    ##
    class Refactor6 < RefactorBase
      def client_1
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      def client_2
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        [0, reading[:base_charge] - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      private

      def enrich_reading(reading)
        result = reading.dup
        result[:base_charge] = base_charge(result)
        result[:tax_threshold] =
          [0, result[:base_charge] - tax_threshold(result[:year])].max
        result
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Update client 3 to use the tax_threshold from the enrich reading
    ##
    class Refactor7 < RefactorBase
      def client_1
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      def client_2
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:tax_threshold]
      end

      def client_3
        raw_reading = READING
        reading = enrich_reading(raw_reading)
        reading[:base_charge]
      end

      private

      def enrich_reading(reading)
        result = reading.dup
        result[:base_charge] = base_charge(result)
        result[:tax_threshold] =
          [0, result[:base_charge] - tax_threshold(result[:year])].max
        result
      end

      def base_charge(reading)
        base_rate(reading[:month], reading[:year]) * reading[:quantity]
      end

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    class Tests
      def call
        [
          BeforeRefactor, Refactor1, Refactor2, Refactor3, Refactor4, Refactor5,
          Refactor6, Refactor7,
        ].each do |klass|
          instance = klass.new
          puts_each_client(instance)
        end
      end

      private

      def puts_each_client(instance)
        puts "Client 1: #{instance.client_1 == 100_850}"
        puts "Client 2: #{instance.client_2 == 98_833}"
        puts "Client 3: #{instance.client_3 == 100_850}"
      end
    end
  end
end
