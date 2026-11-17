module Atmospheric
  class TaxonomyGenerator < Jekyll::Generator
    safe true
    priority :low

    def generate(site)
      albums = site.collections["albums"]&.docs || []

      # ---------- ЖАНРЫ ----------
      genres = {}
      albums.each do |a|
        Array(a.data["genres"]).each do |g|
          slug = make_slug(g)
          genres[slug] ||= { "name" => g, "items" => [] }
          genres[slug]["items"] << a
        end
      end
      genres.each do |slug, data|
        page = PageWithoutAFile.new(site, site.source, "tags", "#{slug}.html")
        page.data.merge!(
          "layout" => "taxonomy",
          "title" => data["name"],
          "heading" => data["name"],
          "type" => "жанр",
          "items" => data["items"],
          "slug" => slug
        )
        page.content = ""
        site.pages << page
      end

      # ---------- ГРУППЫ ----------
      artists = {}
      albums.each do |a|
        slug = make_slug(a.data["artist"])
        artists[slug] ||= { "name" => a.data["artist"], "items" => [] }
        artists[slug]["items"] << a
      end
      artists.each do |slug, data|
        page = PageWithoutAFile.new(site, site.source, "bands", "#{slug}.html")
        page.data.merge!(
          "layout" => "taxonomy",
          "title" => data["name"],
          "heading" => data["name"],
          "type" => "группа",
          "items" => data["items"],
          "slug" => slug
        )
        page.content = ""
        site.pages << page
      end

      # ---------- СТРАНЫ ----------
      countries = {}
      albums.each do |a|
        next if a.data["country"].to_s.empty?
        slug = make_slug(a.data["country"])
        countries[slug] ||= { "name" => a.data["country"], "items" => [] }
        countries[slug]["items"] << a
      end
      countries.each do |slug, data|
        page = PageWithoutAFile.new(site, site.source, "countries", "#{slug}.html")
        page.data.merge!(
          "layout" => "taxonomy",
          "title" => data["name"],
          "heading" => data["name"],
          "type" => "страна",
          "items" => data["items"],
          "slug" => slug
        )
        page.content = ""
        site.pages << page
      end
    end

    private

    # Транслитерация кириллицы в латиницу + очистка под URL
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
