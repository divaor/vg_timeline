module PressHelper

  def press_list(press)
    ls = content_tag(:tr, content_tag(:th, "Name") + content_tag(:th, "Scale") + content_tag(:th, "URL"))
    press.each do |p|
      row = ''
      row += content_tag(:td, p.name)
      row += content_tag(:td, (text_field_tag "scl#{p.id}", p.scale, :size => 5, :maxlength => 5))
      row += content_tag(:td, (text_field_tag "url#{p.id}", p.url, :size => 15))
      ls += content_tag(:tr, raw(row))
    end
    list = content_tag(:table, raw(ls))
    list += submit_tag "Submit"
    raw list
  end
end
