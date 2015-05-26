require 'PDFlib'

class ShapesController < ApplicationController

  before_action :initialize_and_configure_pdf

  SEARCH_PATH = "#{Rails.root}/app/assets/images"
  IMAGE = "lionel.jpg"
  RADIUS = 200.0
  MARGIN = 20.0

  def hello_rails
    @pdf.begin_page_ext(595, 842, "")
    font = @pdf.load_font("Helvetica-Bold", "winansi", "")
    @pdf.setfont(font, 24)
    @pdf.set_text_pos(50, 700)
    @pdf.show("Hello world!")
    @pdf.continue_text("(says Ruby)")
    finish_pdf
    send_pdf

  rescue  PDFlibException => pe
    handle_error(pe)
  end

  def image
    image = @pdf.load_image("auto", IMAGE, "")
    
    # dummy page size, will be adjusted by PDF_fit_image()
    @pdf.begin_page_ext(10, 10, "")
    @pdf.fit_image(image, 0.0, 0.0, "adjustpage")
    @pdf.close_image(image)
    finish_pdf
    send_pdf

  rescue  PDFlibException => pe
    handle_error(pe)
  end

  def random_shape
    @pdf.begin_page_ext(0, 0, "width=letter.width height=letter.height")

    @pdf.circle(500, 300, 100)
    @pdf.fill

    @pdf.setlinewidth(2.0)
    @pdf.setcolor("fillstroke", "rgb", 0.0, 0.0, 1.0, 0.0)
    @pdf.moveto(40, 380)
    @pdf.lineto(95, 385)
    @pdf.lineto(95, 455)
    @pdf.lineto(40, 450)

    @pdf.moveto(40, 450)
    @pdf.lineto(40, 380)
    @pdf.lineto(95, 455)
    @pdf.stroke

    

    finish_pdf
    send_pdf
  end

  def clock   
    time = Time.now
    @pdf.begin_page_ext( (2 * (RADIUS + MARGIN)), (2 * (RADIUS + MARGIN)), "")

    @pdf.translate(RADIUS + MARGIN, RADIUS + MARGIN)
    @pdf.setcolor("fillstroke", "rgb", 0.0, 0.0, 1.0, 0.0)
    @pdf.save

    # minute strokes 
    @pdf.setlinewidth(2.0)
    0.step(360, 6) do |alpha|
      @pdf.rotate(6.0)
      @pdf.moveto(RADIUS, 0.0)
      @pdf.lineto(RADIUS-MARGIN/3, 0.0)
      @pdf.stroke
    end

    @pdf.restore
    @pdf.save

    # 5 minute strokes
    @pdf.setlinewidth(3.0)
    0.step(360, 30) do |alpha|
      @pdf.rotate(30.0)
      @pdf.moveto(RADIUS, 0.0)
      @pdf.lineto(RADIUS-MARGIN, 0.0)
      @pdf.stroke
    end

    # draw hour hand 
    @pdf.save
    @pdf.rotate((-((time.min/60.0) + time.hour - 3.0) * 30.0))
    @pdf.moveto(-RADIUS/10, -RADIUS/20)
    @pdf.lineto(RADIUS/2, 0.0)
    @pdf.lineto(-RADIUS/10, RADIUS/20)
    @pdf.closepath
    @pdf.fill
    @pdf.restore

    # draw minute hand
    @pdf.save
    @pdf.rotate((-((time.sec/60.0) + time.min - 15.0) * 6.0))
    @pdf.moveto(-RADIUS/10, -RADIUS/20)
    @pdf.lineto(RADIUS * 0.8, 0.0)
    @pdf.lineto(-RADIUS/10, RADIUS/20)
    @pdf.closepath
    @pdf.fill
    @pdf.restore

    # draw second hand
    @pdf.setcolor("fillstroke", "rgb", 1.0, 0.0, 0.0, 0.0)
    @pdf.setlinewidth(2)
    @pdf.save
    @pdf.rotate(-((time.sec - 15.0) * 6.0))
    @pdf.moveto(-RADIUS/5, 0.0)
    @pdf.lineto(RADIUS, 0.0)
    @pdf.stroke
    @pdf.restore

    # draw little circle at center
    @pdf.circle(0, 0, RADIUS/30)
    @pdf.fill

    @pdf.restore
    finish_pdf
    send_pdf

  rescue  PDFlibException => pe
    handle_error(pe)
  end

  protected

  def initialize_and_configure_pdf
    @pdf = PDFlib.new
    @pdf.set_option("errorpolicy=exception")
    @pdf.set_option("stringformat=utf8")
    @pdf.set_option("SearchPath={{#{SEARCH_PATH}}}")

    @pdf.begin_document("", "")
    @pdf.set_info("Creator", "ShapesController##{action_name}")
    @pdf.set_info("Author", "Smarty McAuthorson")
    @pdf.set_info("Title", "#{action_name} PDF Example")
  end

  def finish_pdf
    @pdf.end_page_ext("")
    @pdf.end_document("")
  end

  def send_pdf
    send_data @pdf.get_buffer, filename: "#{action_name}.pdf",
     type: "application/pdf;base64", disposition: "inline"
  end

  def handle_error(error)
    log_msg = "[#{error.get_errnum.to_s}] #{error.get_apiname}: #{error.get_errmsg}"

    Rails.logger.info "*** PDFlib exception occurred in #{action_name} sample: ***"
    Rails.logger.info log_msg
  end
end