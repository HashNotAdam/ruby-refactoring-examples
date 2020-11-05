# frozen_string_literal: true

require "ostruct"

# @see https://memberservices.informit.com/my_account/webedition/9780135425664/html/combinefunctionsintoclass.html

# Goal: take a group of functions that work on a common body of data and extract
#       them into their own class

module FirstSetOfRefactorings
  module CombineFunctionsIntoAClass
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

      # This client is using the helpful base_charge method to do what the
      # earlier clients are manually calculating. There is a natural impulse to
      # change the earlier code to use this method. The trouble with top-level
      # functions is that they are easy to miss and it is better to change the
      # code to give the method a closer connection to the data it processes
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
        base_rate(reading[:month], reading[:year]) * reading[:quantity];
      end
    end

    ##
    # Turn the record into a class using Encapsulate Record
    ##
    class Reading
      attr_reader :customer
      attr_reader :quantity
      attr_reader :month
      attr_reader :year

      def initialize(data)
        @customer = data[:customer]
        @quantity = data[:quantity]
        @month = data[:month]
        @year = data[:year]
      end
    end

    ##
    # Start the migration with the method we already have (base_charge)
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
        reading = Reading.new(raw_reading)
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
        base_rate(reading.month, reading.year) * reading.quantity
      end
    end

    ##
    # Use Move Function to move base_charge into the new class
    ##
    class Reading
      def base_charge
        base_rate * quantity
      end

      private

      def base_rate
        month * year
      end
    end

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
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      private

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Alter the first client to call the method rather than repeat the
    # calculation
    ##
    class Refactor3 < RefactorBase
      def client_1
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      def client_2
        reading = READING
        base = base_rate(reading[:month], reading[:year]) * reading[:quantity]
        [0, base - tax_threshold(reading[:year])].max
      end

      def client_3
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      private

      def base_rate(month, year)
        month * year
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Alter the second client to call the method rather than repeat the
    # calculation
    ##
    class Refactor4 < RefactorBase
      def client_1
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      def client_2
        raw_reading = READING
        reading = Reading.new(raw_reading)
        [0, reading.base_charge - tax_threshold(reading.year)].max
      end

      def client_3
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      private

      def tax_threshold(year)
        year
      end
    end

    ##
    # Use Extract Function on the calculation for the taxable charge
    ##
    class Refactor5 < RefactorBase
      def client_1
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      def client_2
        raw_reading = READING
        reading = Reading.new(raw_reading)
        taxable_charge(reading)
      end

      def client_3
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      private

      def taxable_charge(reading)
        [0, reading.base_charge - tax_threshold(reading.year)].max
      end

      def tax_threshold(year)
        year
      end
    end

    ##
    # Then apply Move Function
    ##
    class Reading
      def taxable_charge
        [0, base_charge - tax_threshold].max
      end

      private

      def tax_threshold
        year
      end
    end

    class Refactor6 < RefactorBase
      def client_1
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end

      def client_2
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.taxable_charge
      end

      def client_3
        raw_reading = READING
        reading = Reading.new(raw_reading)
        reading.base_charge
      end
    end

    class Tests
      def call
        [
          BeforeRefactor, Refactor1, Refactor2, Refactor3, Refactor4, Refactor5,
          Refactor6,
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
