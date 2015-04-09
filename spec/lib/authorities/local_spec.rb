require 'spec_helper'

describe Qa::Authorities::Local do

  describe "new" do
    it "should raise an error" do
      expect { described_class.new }.to raise_error
    end
  end

  describe ".factory" do
    context "without a sub-authority" do
      it "should raise an error is the sub-authority is not provided" do
        expect { described_class.factory }.to raise_error
      end
      it "should raise an error is the sub-authority does not exist" do
        expect { described_class.factory("foo") }.to raise_error
      end
    end

    context "with a sub authority" do
      subject { described_class.factory("authority_A") }
      it "should return a file authority" do
        expect(subject).to be_kind_of Qa::Authorities::Local::FileBasedAuthority
      end
    end
  end

  describe ".register" do
    before do
      class SolrAuthority
        def initialize(one)
        end
      end
      described_class.register_factory('new_sub', 'SolrAuthority')
    end

    after { Object.send(:remove_const, :SolrAuthority) }

    it "adds an entry to sub_authorities" do
      expect(described_class.sub_authorities).to include 'new_sub'
    end

    it "creates authorities of the proper type" do
      expect(described_class.factory('new_sub')).to be_kind_of SolrAuthority
    end
  end
end