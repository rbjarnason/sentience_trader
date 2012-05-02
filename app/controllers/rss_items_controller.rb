# encoding: UTF-8

class RssItemsController < ApplicationController
  layout "main"

  # GET /rss_items
  # GET /rss_items.xml
  def index
    @rss_items = RssItem.find(:all)

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @rss_items }
    end
  end
  
  def parse_paragraphs
    @rss_item = RssItem.find(params[:id])
  end

  def sample_by_target
    quote_targets = QuoteTarget.find(:all)
    @rss_items = []
    quote_targets.each do |target|
      only_active = target.rss_items.only_active
      if only_active
        toval = [9,only_active.length].min
        @rss_items << [target.id, only_active[0..toval]]
      end
    end
    respond_to do |format|
      format.html
      format.xml  { render :xml => @rss_items }
    end
  end
  
  def get_one_to_rate
    stop = false
    rss_item = nil
    quote_target_id = nil
    unclassified_paragraph = ClassifiedParagraph.find(:first, :conditions=>"sentiment_score IS NULL AND objective_subjective_score IS NULL", :order=>"rand()")
    if unclassified_paragraph
      rss_item = unclassified_paragraph.rss_item
      quote_target_id = unclassified_paragraph.quote_target.id
    else      
      QuoteTarget.find(:all, :order => "rand()").each do |q|
        q.rss_items.by_rand.each do |r|
          puts "#{r.title} #{r.classified_paragraphs.count}"
          unless r.classified_paragraphs.hasone?(q.id)
            rss_item = r
            quote_target_id = q.id
            stop = true
            break
          end
        end
        break if stop
      end
    end
    
    if rss_item  
      redirect_to :action=>"show", :id=>rss_item.id, :quote_target_id=>quote_target_id
    else
      respond_to do |format|
        format.html
      end
    end
  end
  
  def rate_paragraphs
    params.each do |param,parama|
      if param.to_s[0..6]=="values_"
        id = param.split("_")[1].to_i
        cp = ClassifiedParagraph.find(id)
        cp.set_sentiment_from_slider(parama["sv"].to_i)
        cp.set_objective_from_slider(parama["ov"].to_i)
        cp.modified_by_user_id = session[:user_id]
        cp.save
      end
    end
    if params[:commit]=="Rate those paragraphs and get the next one"
      flash[:notice] = 'Rating was saved, here is the next one'
      redirect_to :action=>"get_one_to_rate"
    else
      flash[:notice] = 'Rating was saved'
      redirect_to :action=>"show", :id=>params[:rss_item_id], :quote_target_id=>params[:quote_target_id]
    end
  end

  # GET /rss_items/1
  # GET /rss_items/1.xml
  def show
    @rss_item = RssItem.find(params[:id])
    @quote_target = QuoteTarget.find(params[:quote_target_id].to_i)
    @all_rated_paragraphs_count = ClassifiedParagraph.count(:conditions=>["sentiment_score IS NOT NULL AND objective_subjective_score IS NOT NULL"])
    @my_rated_paragraphs_count = ClassifiedParagraph.count(:conditions=>["modified_by_user_id = ?",session[:user_id]])
    
#    if @rss_item.paragraphs(@quote_target.id).length==0
#      flash[:notice] = 'Previous did not have any paragraphs to show'
#      redirect_to :action=>"get_one_to_rate"
#    else    
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @rss_item }
      end
#    end
  end

  # GET /rss_items/new
  # GET /rss_items/new.xml
  def new
    @rss_item = RssItem.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @rss_item }
    end
  end

  # GET /rss_items/1/edit
  def edit
    @rss_item = RssItem.find(params[:id])
  end

  # POST /rss_items
  # POST /rss_items.xml
  def create
    @rss_item = RssItem.new(params[:rss_item])

    respond_to do |format|
      if @rss_item.save
        flash[:notice] = 'RssItem was successfully created.'
        format.html { redirect_to(@rss_item) }
        format.xml  { render :xml => @rss_item, :status => :created, :location => @rss_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @rss_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /rss_items/1
  # PUT /rss_items/1.xml
  def update
    @rss_item = RssItem.find(params[:id])

    respond_to do |format|
      if @rss_item.update_attributes(params[:rss_item])
        flash[:notice] = 'RssItem was successfully updated.'
        format.html { redirect_to(@rss_item) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @rss_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /rss_items/1
  # DELETE /rss_items/1.xml
  def destroy
    @rss_item = RssItem.find(params[:id])
    @rss_item.destroy

    respond_to do |format|
      format.html { redirect_to(rss_items_url) }
      format.xml  { head :ok }
    end
  end
end
