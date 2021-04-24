module LogoAttachmentHelper
  def attach_logo
    logo =  "data:image/jpeg;base64;#{Base64.strict_encode64(File.open(Rails.root.join('public/tattoo.jpg')).read)}"
    return logo
  end
end
