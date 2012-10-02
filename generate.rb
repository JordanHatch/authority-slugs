require 'ostruct'
require 'net/http'
require 'json'

class AuthoritySlugGenerator < OpenStruct
  def mapit_url
    @mapit_url || 'http://mapit.mysociety.org/'
  end

  def authority_types
    @authority_types || ['CTY','UTA','DIS','LBO','LGD','MTD']
  end

  def fetch_slugs
    authorities = fetch_authorities
    slugs = authorities.values.map {|authority|
      [ slug_for_authority_name(authority["name"]), { "ons" => authority["codes"]["ons"], "gss" => authority["codes"]["gss"] } ]
    }
    Hash[slugs]
  end

  def fetch_authorities
    json = Net::HTTP.get( URI.parse( mapit_url + 'areas/' + authority_types.join(',') ))
    authorities = JSON::parse(json)
  end

  def slug_for_authority_name(name)
    normalized_authority_name = name.sub(/(District|County|Borough|City)? (Council|Corporation)?$/, '').strip
    normalized_authority_name.downcase.gsub(/[^A-Za-z0-9\s]/,'').gsub(/\s+/, '-')
  end
end

slugs = AuthoritySlugGenerator.new.fetch_slugs
json = JSON.pretty_generate(slugs)

File.open('authorities.json', 'w') do |f|
  f.write(json)
end
