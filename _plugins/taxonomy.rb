module Atmospheric
  class TaxonomyGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      albums = site.collections["albums"]&.docs || []

      genres = {}
      artists = {}
      countries = {}
      labels = {}

      albums.each do |a|
        Array(a.data["genres"]).each do |g|
          slug = make_slug(g)
          genres[slug] ||= { "name" => g, "items" => [] }
          genres[slug]["items"] << a
        end

        slug = make_slug(a.data["artist"])
        artists[slug] ||= { "name" => a.data["artist"], "items" => [] }
        artists[slug]["items"] << a

        c = a.data["country"].to_s
        unless c.empty?
          slug = make_slug(c)
          countries[slug] ||= { "name" => c, "items" => [] }
          countries[slug]["items"] << a
        end

        l = a.data["label"].to_s
        unless l.empty?
          slug = make_slug(l)
          labels[slug] ||= { "name" => l, "items" => [] }
          labels[slug]["items"] << a
        end
      end

      albums.each do |a|
        a.data["genre_links"] = Array(a.data["genres"]).map do |g|
          { "name" => g, "url" => "/tags/#{make_slug(g)}.html" }
        end

        a.data["artist_url"] = "/bands/#{make_slug(a.data['artist'])}.html"

        c = a.data["country"].to_s
        a.data["country_url"] = c.empty? ? nil : "/countries/#{make_slug(c)}.html"

        l = a.data["label"].to_s
        a.data["label_url"] = l.empty? ? nil : "/labels/#{make_slug(l)}.html"
      end

      genres.each    { |slug, data| add_page(site, "tags",      slug, "жанр",   data) }
      artists.each   { |slug, data| add_page(site, "bands",     slug, "группа", data) }
      countries.each { |slug, data| add_page(site, "countries", slug, "страна", data) }
      labels.each    { |slug, data| add_page(site, "labels",    slug, "лейбл",  data) }
    end

    private

    def add_page(site, dir, slug, type, data)
      page = Jekyll::PageWithoutAFile.new(site, site.source, dir, "#{slug}.html")
      page.data.merge!(
        "layout"  => "taxonomy",
        "title"   => data["name"],
        "heading" => data["name"],
        "type"    => type,
        "items"   => data["items"],
        "slug"    => slug
      )
      page.content = ""
      site.pages << page
    end

    def make_slug(text)
      map = {
        "а"=>"a","б"=>"b","в"=>"v","г"=>"g","д"=>"d","е"=>"e","ё"=>"e",
        "ж"=>"zh","з"=>"z","и"=>"i","й"=>"y","к"=>"k","л"=>"l","м"=>"m",
        "н"=>"n","о"=>"o","п"=>"p","р"=>"r","с"=>"s","т"=>"t","у"=>"u",
        "ф"=>"f","х"=>"kh","ц"=>"ts","ч"=>"ch","ш"=>"sh","щ"=>"shch",
        "ъ"=>"","ы"=>"y","ь"=>"","э"=>"e","ю"=>"yu","я"=>"ya"
      }
      text.to_s.downcase.chars.map { |c| map[c] || c }.join
        .gsub(/[^a-z0-9]+/, "-")
        .gsub(/^-+|-+$/, "")
    end
  end
end
