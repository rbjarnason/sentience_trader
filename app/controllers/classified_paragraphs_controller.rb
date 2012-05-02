class ClassifiedParagraphsController < ApplicationController
  layout "main"

  # GET /classified_paragraphs
  # GET /classified_paragraphs.xml
  def index
    @classified_paragraphs = ClassifiedParagraph.find(:all, :order=>"modified_by_user_id")

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @classified_paragraphs }
    end
  end

  # GET /classified_paragraphs/1
  # GET /classified_paragraphs/1.xml
  def show
    @classified_paragraph = ClassifiedParagraph.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @classified_paragraph }
    end
  end

  # GET /classified_paragraphs/new
  # GET /classified_paragraphs/new.xml
  def new
    @classified_paragraph = ClassifiedParagraph.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @classified_paragraph }
    end
  end

  # GET /classified_paragraphs/1/edit
  def edit
    @classified_paragraph = ClassifiedParagraph.find(params[:id])
  end

  # POST /classified_paragraphs
  # POST /classified_paragraphs.xml
  def create
    @classified_paragraph = ClassifiedParagraph.new(params[:classified_paragraph])

    respond_to do |format|
      if @classified_paragraph.save
        flash[:notice] = 'ClassifiedParagraph was successfully created.'
        format.html { redirect_to(@classified_paragraph) }
        format.xml  { render :xml => @classified_paragraph, :status => :created, :location => @classified_paragraph }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @classified_paragraph.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /classified_paragraphs/1
  # PUT /classified_paragraphs/1.xml
  def update
    @classified_paragraph = ClassifiedParagraph.find(params[:id])

    respond_to do |format|
      if @classified_paragraph.update_attributes(params[:classified_paragraph])
        flash[:notice] = 'ClassifiedParagraph was successfully updated.'
        format.html { redirect_to(@classified_paragraph) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @classified_paragraph.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /classified_paragraphs/1
  # DELETE /classified_paragraphs/1.xml
  def destroy
    @classified_paragraph = ClassifiedParagraph.find(params[:id])
    @classified_paragraph.destroy

    respond_to do |format|
      format.html { redirect_to(classified_paragraphs_url) }
      format.xml  { head :ok }
    end
  end
end
