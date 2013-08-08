# encoding: UTF-8

module Enumerable
  def frequencies
    group_by {|c| c }.map {|c, cs| [c, cs.length] }
  end
end

class Array
  def median
    sorted = self.sort
    len = sorted.length
    return ((sorted[(len - 1) / 2] + sorted[len / 2]) / 2.0).round(1)
  end
end
