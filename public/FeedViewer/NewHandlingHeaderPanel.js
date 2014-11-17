/**
 * @class FeedViewer.FeedPanel
 * @extends Ext.panel.Panel
 *
 * Shows a list of available feeds. Also has the ability to add/remove and load feeds.
 *
 * @constructor
 * Create a new Feed Panel
 * @param {Object} config The config object
 */

Ext.define('FeedViewer.NewHandlingHeaderPanel', {
    extend: 'Ext.window.Window',

    alias: 'widget.newhandlingheaderpanel',

    animCollapse: true,
    layout: 'fit',
    title: 'Inserimento nuovo movimento',
    modal: true,

    /**
     * @event feedremove Fired when a feed is removed
     * @param {FeedPanel} this
     * @param {String} title The title of the feed
     * @param {String} url The url of the feed
     */

    /**
     * @event feedselect Fired when a feed is selected
     * @param {FeedPanel} this
     * @param {String} title The title of the feed
     * @param {String} url The url of the feed
     */

    initComponent: function(){
        Ext.apply(this, {
            items: this.createView(),
            height: 300,
    		width: 540
        });
        this.callParent(arguments);
    },

    /**
     * Create the DataView to be used for the feed list.
     * @private
     * @return {Ext.view.View}
     */
    createView: function(){
    	    	    	
    	
        this.view = Ext.create('Ext.form.Panel', {
        	bodyPadding: 10,
        	layout: {
        	    type: 'vbox', align : 'stretch', pack: 'start'
        	},
        	items: [

	        	//ricerca numero container
	        		{
					xtype: 'fieldset', border: false, flex: 1,
					items: [        	
	        			{"fieldLabel":"Inserisci il numero container","name":"container_number", "xtype": "textfield", "labelAlign": "top", "anchor": "100%"},
	        			{xtype: "button", text: "Verifica e inserisci", iconCls: 'fa fa-search'}
	        		]}
        		
        		//HELP
	        		, {
	        		  layout: 'fit', heigt: 50, cls: 'app_info', border: true,
					  html: '<i class="fa fa-info-circle"></i>Verrà ricercato il movimento aperto relativo al numero container inserito<br/> o verrà generato un nuovo movimento'
					}
        		
        	]
        	});
        return this.view;
    },

    onViewReady: function(){
    },


    // Inherit docs
    onDestroy: function(){
        this.callParent(arguments);
    }
});
