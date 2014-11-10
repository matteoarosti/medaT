Ext.define("Porto", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/terminal_movs/sc_read',
            create: '/terminal_movs/sc_create',
            update: '/terminal_movs/sc_update',
            destroy: '/terminal_movs/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data'
        },        
    },
	validations: [
	        //{type: 'presence',  field: 'age'},
	        //{type: 'length',    field: 'denominazione',     min: 6},
	        //{type: 'inclusion', field: 'gender',   list: ['Male', 'Female']},
	        //{type: 'exclusion', field: 'username', list: ['Admin', 'Operator']},
	        //{type: 'format',    field: 'username', matcher: /([a-z]+)[0-9]{2,3}/}
	    ]    
});


Ext.define("Shipowner", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/shipowners/sc_read',
            create: '/shipowners/sc_create',
            update: '/shipowners/sc_update',
            destroy: '/shipowners/sc_destroy'
        },
        reader: {
            type: 'json',
            successProperty: 'success',
            rootProperty: 'items',
            messageProperty: 'message'
        },
        writer: {
            type: 'json',
            writeAllFields: false,
            rootProperty: 'data',
            getRecordData: function (record)
        		{
        			console.log('getRecordData');
          			return { 'data': Ext.JSON.encode(record.data) };
        		}
        },        
    }    
});