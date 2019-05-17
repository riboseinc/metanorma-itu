module Asciidoctor
  module ITU
    class Converter < Standoc::Converter
      def bibdata_validate(doc)
        doctype_validate(doc)
        stage_validate(doc)
      end

      def doctype_validate(xmldoc)
        doctype = xmldoc&.at("//bibdata/ext/doctype")&.text
        %w(recommendation recommendation-supplement recommendation-amendment 
        recommendation-corrigendum recommendation-errata recommendation-annex 
        focus-group implementers-guide technical-paper technical-report 
        joint-itu-iso-iec).include? doctype or
          warn "Document Attributes: #{doctype} is not a recognised document type"
      end

      def stage_validate(xmldoc)
        stage = xmldoc&.at("//bibdata/status/stage")&.text
        %w(in-force superseded in-force-prepublished withdrawn).include? stage or
          warn "Document Attributes: #{stage} is not a recognised status"
      end

      def content_validate(doc)
        super
        approval_validate(doc)
        itu_identifier_validate(doc)
        bibdata_validate(doc.root)
      end

      def approval_validate(xmldoc)
        s = xmldoc.at("//bibdata/recommendationstatus") || return
        process = s.at("./@process").text
        if process == "aap" and %w(determined in-force).include? s.text
          warn "Recommendation Status #{s.text} inconsistent with AAP"
        end
        if process == "tap" and !%w(determined in-force).include? s.text
          warn "Recommendation Status #{s.text} inconsistent with TAP"
        end
      end

      def itu_identifier_validate(xmldoc)
        s = xmldoc.xpath("//bibdata/docidentifier[@type = 'ITU']").each do |x|
          /^ITU-[RTF] [AD-VX-Z]\.[0-9]+$/.match x.text or
            warn "#{x.text} does not match ITU document identifier conventions"
        end
      end

    end
  end
end

DocumentType =
  "recommendation" | "recommendation-supplement" | "recommendation-amendment" | "recommendation-corrigendum" | "recommendation-errata" |
  "recommendation-annex" | "focus-group" | "implementers-guide" | "technical-paper" | "technical-report" | "joint-itu-iso-iec"
