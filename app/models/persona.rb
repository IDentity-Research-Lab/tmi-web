# A Persona is a composite entity linking Cases, Codes, Identities, and Keywords.
# Each Persona embodies the unique characteristics captured about a specific study participant as a data avatar.

class Persona
  include ActiveGraph::Node

  property :name
  property :case_id
  property :permalink

  validates :name, presence: true
  validates :case_id, presence: true

  has_many :out, :codes, rel_class: :Experiences, dependent: :delete_orphans
  has_many :out, :identities, rel_class: :IdentifiesWith, dependent: :delete_orphans
  has_many :out, :keywords, rel_class: :ReflectsOn, dependent: :delete_orphans

  # Traverses the codes-[]-categories relationship to return a list of unique Categories.
  def categories
    @categories ||= self.codes.map(&:categories).flatten.uniq
  end

end
