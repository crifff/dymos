module Dymos
  module Query
    class Expect < Attribute
      def initialize
      end

      def condition(operator, value)
        if value.present?
          value1, value2 = value.split(" ")
          value1 =value1.to_i if /^[0-9]+$/.match(value1)
          value2 =value2.to_i if /^[0-9]+$/.match(value2)
          @value = value1
        end

        case operator.to_sym
          when :==, :eq
            @operator = 'EQ'
          when :!=, :nq
            @operator = 'NE'
          when :<=, :le
            @operator = 'LE'
          when :<, :lt
            @operator = 'LT'
          when :>=, :ge
            @operator = 'GE'
          when :>, :gt
            @operator = 'GT'
          when :between
            @operator = 'BETWEEN'
            @value =[value1, value2]
          when :is_null
            @operator = 'NULL'
          when :is_not_null
            @operator = 'NOT_NULL'
          when :contains
            @operator = 'CONTAINS'
          when :not_contains
            @operator = 'NOT_CONTAINS'
          when :begins_with
            @operator = 'BEGINS_WITH'
          else
            raise ArgumentError, '%s is not defined ' % operator
        end
        self
      end

      # def equal(value)
      #   @operator = 'EQ'
      #   @value = value
      # end
      # 
      # def not_equal(value)
      #   @operator = 'NE'
      #   @value = value
      # end
      # 
      # def less_then_equal(value)
      #   @operator = 'LE'
      #   @value = value
      # end
      # 
      # def less_then(value)
      #   @operator = 'LT'
      #   @value = value
      # end
      # 
      # def <=(value)
      #   @operator = 'GE'
      #   @value = value
      # end
      # 
      # def <(value)
      #   @operator = 'GT'
      #   @value = value
      # end
      # 
      # def between(value1, value2)
      #   @operator = 'BETWEEN'
      #   @value = [value1, value2]
      # end
      # 
      # def is_not_null
      #   @operator = 'NOT_NULL'
      # end
      # 
      # def is_null
      #   @operator = 'NULL'
      # end
      # 
      # def contains(value)
      #   @operator = 'CONTAINS'
      #   @value = value
      # end
      # 
      # def not_contains(value)
      #   @operator = 'NOT_CONTAINS'
      #   @value = value
      # end
      # 
      # def begins_with(value)
      #   @operator = 'BEGINS_WITH'
      #   @value = value
      # end

      def data
        value = super
        if value.is_a? Array
          data = {
              attribute_value_list: value,
              comparison_operator: @operator
          }
        else
          data = {}
          data[:value]= value if value.present?
          data[:comparison_operator]= @operator
        end

        data[:exists] = true if @exists.present?
        data
      end
    end
  end
end