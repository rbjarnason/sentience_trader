class RssItemScoresController < ApplicationController
  layout "main"

  # GET /rss_item_scores
  # GET /rss_item_scores.xml
  def index
    @rss_item_scores = RssItemScore.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rss_item_scores }
    end
  end

  # GET /rss_item_scores/1
  # GET /rss_item_scores/1.xml
  def show
    @rss_item_score = RssItemScore.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @rss_item_score }
    end
  end

  # GET /rss_item_scores/new
  # GET /rss_item_scores/new.xml
  def new
    @rss_item_score = RssItemScore.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rss_item_score }
    end
  end

  # GET /rss_item_scores/1/edit
  def edit
    @rss_item_score = RssItemScore.find(params[:id])
  end

  # POST /rss_item_scores
  # POST /rss_item_scores.xml
  def create
    @rss_item_score = RssItemScore.new(params[:rss_item_score])

    respond_to do |format|
      if @rss_item_score.save
        flash[:notice] = 'RssItemScore was successfully created.'
        format.html { redirect_to(@rss_item_score) }
        format.xml  { render :xml => @rss_item_score, :status => :created, :location => @rss_item_score }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rss_item_score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rss_item_scores/1
  # PUT /rss_item_scores/1.xml
  def update
    @rss_item_score = RssItemScore.find(params[:id])

    respond_to do |format|
      if @rss_item_score.update_attributes(params[:rss_item_score])
        flash[:notice] = 'RssItemScore was successfully updated.'
        format.html { redirect_to(@rss_item_score) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rss_item_score.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rss_item_scores/1
  # DELETE /rss_item_scores/1.xml
  def destroy
    @rss_item_score = RssItemScore.find(params[:id])
    @rss_item_score.destroy

    respond_to do |format|
      format.html { redirect_to(rss_item_scores_url) }
      format.xml  { head :ok }
    end
  end
end
