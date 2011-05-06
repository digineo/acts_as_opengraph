module ActsAsOpengraphHelper
  # Generates the opengraph meta tags for your views
  #
  # @param [Object, #opengraph_data] obj An instance of your ActiveRecord model that responds to opengraph_data
  # @return [String] A set of meta tags describing your graph object based on the {http://ogp.me/ opengraph protocol}
  # @raise [ArgumentError] When you pass an instance of an object that doesn't responds to opengraph_data (maybe you forgot to add acts_as_opengraph in your model)
  # @example
  #   opengraph_meta_tags_for(@movie)
  def opengraph_meta_tags_for(obj)
    raise(ArgumentError.new, "You need to call acts_as_opengraph on your #{obj.class} model") unless obj.respond_to?(:opengraph_data)
    tags = obj.opengraph_data.map do |att|
      %(<meta property="#{att[:name].dasherize}" content="#{Rack::Utils.escape_html(att[:value])}"/>)
    end
    tags = tags.join("\n")
    tags.respond_to?(:html_safe) ? tags.html_safe : tags
  end

  # Displays the Facebook Like Button in your views.
  #
  # @param [Object, #opengraph_data] obj An instance of your ActiveRecord model that responds to opengraph_data
  # @param [Hash] options A Hash of {http://developers.facebook.com/docs/reference/plugins/like/ supported attributes}. Defaults to { :layout => :standard, :show_faces => false, :width => 450, :action => :like, :colorscheme => :light }
  # @return [String] An iFrame version of the Facebook Like Button
  # @raise [ArgumentError] When you pass an instance of an object that doesn't responds to opengraph_data (maybe you forgot to add acts_as_opengraph in your model)
  # @example
  #   like_button_for(@movie)
  #   like_button_for(@movie, :layout => :button_count, :display_faces => true)
  # @example Specifying href using rails helpers
  #   like_button_for(@movie, :href => movie_url(@movie))
  def like_button_for(obj, options = {})
    raise(ArgumentError.new, "You need to call acts_as_opengraph on your #{obj.class} model") unless obj.respond_to?(:opengraph_data)
    href = options[:href] ? options[:href] : obj.opengraph_url
    return unless href.present?

    config = { :layout => :standard, :show_faces => false, :width => 450, :action => :like, :colorscheme => :light }
    config.update(options) if options.is_a?(Hash)

    o_layout = config[:layout].to_sym
    if o_layout == :standard
      config[:height] = config[:show_faces].to_s.to_sym == :true ? 80 : 35
    elsif o_layout == :button_count
      config[:height] = 21
    elsif o_layout == :box_count
      config[:height] = 65
    end
    config[:locale] ||= 'en_US'

    if config[:xfbml]
      unless @fb_sdk_included
        content_for :opengraph_meta_tags, fb_sdk_meta_tags
      end
      %(<fb:like href="#{CGI.escape(href)}" layout="#{config[:layout]}" show_faces="#{config[:show_faces]}" action="#{config[:action]}" colorscheme="#{config[:colorscheme]}" width="#{config[:width]}" height="#{config[:height]}" font="#{config[:font]}"></fb:like>)
    else
      %(<iframe src="http://www.facebook.com/plugins/like.php?href=#{CGI.escape(href)}&amp;layout=#{config[:layout]}&amp;show_faces=#{config[:show_faces]}&amp;width=#{config[:width]}&amp;action=#{config[:action]}&amp;colorscheme=#{config[:colorscheme]}&amp;height=#{config[:height]}" scrolling="no" frameborder="0" style="border:none; overflow:hidden; width:#{config[:width]}px; height:#{config[:height]}px;" allowTransparency="true"></iframe>)
    end
  end

  def fb_sdk_meta_tags(appid='', locale='en_US')
    @fb_sdk_included = true
    ( %(<meta property="fb:app_id" content="#{Facebook::APP_ID}"/>\n) +
    %(<meta property="fb:locale" content="#{locale}"/>\n) ).html_safe
  end
end
