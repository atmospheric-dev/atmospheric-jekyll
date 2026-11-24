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

        country_list(a).each do |c|
          slug = make_slug(c)
          countries[slug] ||= { "name" => c, "items" => [] }
          countries[slug]["items"] << a
        end

        label_list(a).each do |l|
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

        clist = country_list(a)
        a.data["country_links"] = clist.map do |c|
          { "name" => c, "url" => "/countries/#{make_slug(c)}.html" }
        end
        a.data["country_url"] = clist.first ? "/countries/#{make_slug(clist.first)}.html" : nil

        llist = label_list(a)
        a.data["label_links"] = llist.map do |l|
          { "name" => l, "url" => "/labels/#{make_slug(l)}.html" }
        end
        a.data["label_url"] = llist.first ? "/labels/#{make_slug(llist.first)}.html" : nil
      end

      genres.each    { |slug, data| add_page(site, "tags",      slug, "жанр",   data) }
      artists.each   { |slug, data| add_page(site, "bands",     slug, "группа", data) }
      countries.each { |slug, data| add_page(site, "countries", slug, "страна", data) }
      labels.each    { |slug, data| add_page(site, "labels",    slug, "лейбл",  data) }
    end

    private

    # Страны: массив "countries" или строка "country" (поддержка старых альбомов).
    # Строка вида "Франция / Япония" тоже разбивается на две страны.
    def country_list(album)
      raw = album.data["countries"]
      list = raw.is_a?(Array) ? raw : [album.data["country"]]

      list.flat_map { |c| c.to_s.split("/") }
          .map(&:strip)
          .reject(&:empty?)
          .uniq
    end

    # Лейблы: массив "labels" или строка "label".
    def label_list(album)
      raw = album.data["labels"]
      list = raw.is_a?(Array) ? raw : [album.data["label"]]

      list.map { |l| l.to_s.strip }
          .reject(&:empty?)
          .uniq
    end

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
