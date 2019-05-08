# frozen_string_literal: true

require 'test_helper'

module Humidifier
  module Props
    class StructurePropTest < Minitest::Test
      def test_valid?
        assert build.valid?({})
        assert build.valid?(Humidifier.ref(Object.new))
        assert build.valid?(Humidifier.fn.base64(Object.new))
      end

      def test_rejects_other_values
        refute build.valid?(Object.new)
        refute build.valid?([])
        refute build.valid?(false)
        refute build.valid?(1.0)
      end

      def test_subprop
        assert build.valid?(beta: 'gamma')
        refute build.valid?(beta: 1)
      end

      def test_to_cf
        assert_equal ['Alpha', { 'Beta' => 'gamma' }], build.to_cf(beta: 'gamma')
      end

      def test_to_cf_ref
        actual = build.to_cf(Humidifier.ref('Foo'))
        assert_equal ['Alpha', { 'Ref' => 'Foo' }], actual
      end

      private

      def build
        substructs = {
          'Sub' => {
            'Properties' => { 'Beta' => { 'PrimitiveType' => 'String' } }
          }
        }

        config = { 'Type' => 'Sub' }
        StructureProp.new('Alpha', config, substructs)
      end
    end
  end
end
