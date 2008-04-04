# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper

  FLASH_TYPES = [:success, :failure]

  def render_flash
    result = ""
    for name in FLASH_TYPES
      result += "<div class='flash_#{name}'>#{flash[name]}</div>" if flash[name]
      flash[name] = nil
    end
    return(result.blank? ? nil : "<div id='flash'>#{result}</div>")
  end

  def datetime_format(time,format)
    format = format.gsub(/(%[dHImU])/,'*\1')
    time.strftime(format).gsub(/\*0*/,'')
  end

  # Returns HTML for a Google map containing the +locatable_items+.
  #
  # Adapt the gmaps_on_rails plugin to talk to our locatable items.
  # Return markup containing a Google map with markers for these items, or
  # nil if no items have locations.
  # - "locatable_items" can be one item or an array of them.
  # - A locatable item is anything that responds_to? :location and
  #   :title (yes, our Events and Venues both qualify).
  # - A locatable item with a nil location will be ignored
  #
  # The plugin uses Google Maps automatic zooming to set the scale, but
  # the little overview map obscures such a big chunk of the main map that
  # it's likely to hide some of our markers, so it's off by default.
  def google_map(locatable_items, options={})
    return nil if defined?(GoogleMap::GOOGLE_APPLICATION_ID) == nil
    options[:controls] = [:zoom, :scale, :type] # the default, minus :overview

    # Make the map and our marker(s)
    map = GoogleMap.new(options)
    [locatable_items].flatten.each do |locatable_item|
      location = locatable_item.location
      if location
        map.markers << GoogleMapMarker.new(:map => map,
          :lat => location[0], :lng => location[1],
          :html => link_to(locatable_item.title, locatable_item))
      end
    end
    map.to_html + map.div(nil) unless map.markers.empty?
  end

  # Retrun a string describing the source code version being used, or false/nil if it can't figure out how to find the version.
  def source_code_version
    if File.directory?(File.join(RAILS_ROOT, ".svn"))
      $svn_revision ||= \
        if s = `svn info`
          if m = s.match(/^Revision: (\d+)/s)
            " - SVN revision: #{m[1]}"
          end
        end
    elsif File.directory?(File.join(RAILS_ROOT, ".git"))
      $git_date ||= \
        if s = `git log -1`
          if m = s.match(/^Date: (.+?)$/s)
            " - Git timestamp: #{m[1]}"
          end
        end
    elsif File.directory?(File.join(RAILS_ROOT, ".hg"))
      $git_date ||= \
        if s = `hg id -nibt`
          " - Mercurial revision: #{s}"
        end
    end
  end
end
