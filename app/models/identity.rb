# An Identity is a word or phrase used by a survey participant to self-describe. Identities have associated contexts.
class Identity
  include ActiveGraph::Node

  property :name
  property :context

  before_validation :strip_whitespace

  validates :name, presence: true
  validates :context, presence: true
  validates_uniqueness_of :name, scope: :context

  has_many :in, :personas, rel_class: :IdentifiesWith

  # Generates a hash consisting of Identities and their number of occurrences.
  def self.histogram(context)
    identities = where(context: context).query_as(:i).with('i, count{(i)-[:IDENTIFIES_WITH]-(p:Persona)} AS c').return('i.name, c').order('c DESC')
    identities.inject({}) {|accumulator,identity| accumulator[identity.values[0]] ||= 0; accumulator[identity.values[0]] += identity.values[1]; accumulator}
  end

  def self.orphans
    query_as(:i).with('i, count{(i)-[:IDENTIFIES_WITH]-(:Persona)} AS ct').where('ct = 0').return('i, ct').map(&:first)
  end

  def self.reap_orphans
    query_as(:i).with('i, count{(i)-[:IDENTIFIES_WITH]-(:Persona)} AS ct').where('ct = 0').return('i, ct').map(&:first).each(&:destroy)
  end

  private

  def strip_whitespace
    self.name.strip!
  end

end
