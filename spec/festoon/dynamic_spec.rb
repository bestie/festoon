require "spec_helper"

require "festoon/dynamic"

RSpec.describe Festoon::Dynamic do
  subject(:composed_object) { Festoon::Dynamic.new(underlying_object) }
  let(:underlying_object)   { double(:underlying_object) }

  context "when a method is not implemented by the decorator" do
    let(:arguments) { [double, double] }

    it "delegates messages" do
      expect(underlying_object).to receive(:arbitrary_message)
        .with(*arguments)

      composed_object.arbitrary_message(*arguments)
    end

    it "delegates with the block" do
      allow(underlying_object).to receive(:arbitrary_message).and_yield

      expect { |blk|
        composed_object.arbitrary_message(&blk)
      }.to yield_with_no_args
    end
  end

  context "methods on the underlying object that return self" do
    before do
      allow(underlying_object).to receive(:arbitrary_message)
        .and_return(underlying_object)
    end

    it "returns self to maintain decoration" do
      expect(composed_object.arbitrary_message).to be(composed_object)
    end
  end

  describe "#respond_to?" do
    before do
      allow(underlying_object).to receive(:arbitrary_message)
    end

    it "responds to its own methods" do
      expect(composed_object).to respond_to(:__decompose__)
    end

    it "purports to respond to messages that the underlying object responds to" do
      expect(composed_object).to respond_to(:arbitrary_message)
    end
  end

  describe "#==" do
    let(:object) { Object.new }
    let(:other) { Object.new }

    let(:composed_object) { Festoon::Dynamic.new(object) }

    it "delegates equality to the underlying object" do
      expect(composed_object == object).to be(true)
      expect(composed_object == other).to be(false)
    end

    context "when comparing to another decorator" do
      let(:composed_similar) { Festoon::Dynamic.new(object) }

      it "inverts the operation offering up its underying object for comparison" do
        expect(composed_object == composed_similar).to be(true)
      end
    end
  end

  describe "#__decompose__" do
    let(:base_object) { Object.new }
    let(:middle_wrap) { Festoon::Dynamic.new(base_object) }
    let(:top_wrap) { Festoon::Dynamic.new(middle_wrap) }

    it "recursively unwraps the composed objects into a flat array" do
      expect(top_wrap.__decompose__).to eq([top_wrap, middle_wrap, base_object])
    end
  end
end
