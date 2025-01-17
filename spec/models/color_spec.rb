# == Schema Information
#
# Table name: colors
#
#  id           :integer          not null, primary key
#  pt           :integer
#  name         :string
#  color        :string
#  femininename :string
#
require "spec_helper"

describe Color do
  before { @color = FactoryGirl.build(:color) }

  subject { @color }

  it { should respond_to(:pt) }
  it { should respond_to(:name) }
  it { should respond_to(:femininename) }
  it { should respond_to(:color) }
  
  it { should be_valid }

  # Point
  describe "when point is not present" do
    before { @color.pt = nil }
    it { should_not be_valid }
  end
  
  # Name
  describe "when name is too long" do
    before { @color.name = "a" * 256 }
    it { should_not be_valid }
  end
  
  # Feminine name
  describe "when feminine name is not present" do
    before { @color.femininename = "a" * 256 }
    it { should_not be_valid }
  end

  # Color
  describe "when color is not of length 7" do
    before { @color.color = "#ABCDEFG" }
    it { should_not be_valid }
  end

end
