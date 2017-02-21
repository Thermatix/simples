module Helpers

  module Class_Methods

      def list_reachable_assets
        settings.assets.each_file do |file|
          puts file
        end
      end

      def add_component_endpoints_to_application
        all_components.each { |component| use component}
      end

      def all_components
        @components ||= Component_List.map do |component,type|
          next if type == "context"
          [component.capitalize,"Controller"].inject(Object) {|res,obj|res.const_get(obj)}
        end.compact
      end

  end

  def get_json_payload
    @request_payload
  end

  def css_include_tag file
    <<-HTML
        <link rel="stylesheet" type="text/css" href="#{url_check file,'css'}">
    HTML
  end

  def javascript_include_tag file
    <<-HTML
      <script type="text/javascript" src="#{url_check file,'js'}"></script>
    HTML
  end

  def opal_boot_code_for(file)
    "<script>#{Opal::Processor.load_asset_code(settings.assets, file)}</script>"
  end

  def url_check(file,ext)
    if file =~ /^https?:\/\//
      file
    else
      "assets/#{file}.#{ext}"
    end
  end

  def self.included child
    child.extend Class_Methods
  end

end
