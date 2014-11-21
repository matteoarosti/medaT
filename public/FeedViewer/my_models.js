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


Ext.define("Carrier", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/carriers/sc_read',
            create: '/carriers/sc_create',
            update: '/carriers/sc_update',
            destroy: '/carriers/sc_destroy'
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

Ext.define("Equipment", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/equipment/sc_read',
            create: '/equipment/sc_create',
            update: '/equipment/sc_update',
            destroy: '/equipment/sc_destroy'
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
        }        
    }    
});

Ext.define("Port", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/ports/sc_read',
            create: '/ports/sc_create',
            update: '/ports/sc_update',
            destroy: '/ports/sc_destroy'
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
        }        
    }    
});

Ext.define("Ship", { extend: "Ext.data.Model",
	reference: 'Shipowner',
    fields: [
    	//{name: 'shipowner_id_Name', mapping: 'shipowner.name'},
    	//{name: 'shipowner_id_Name', convert: function(value, rec){console.log(value); console.log(rec); return rec.data.shipowner.name;}}
    ],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/ships/sc_read',
            create: '/ships/sc_create',
            update: '/ships/sc_update',
            destroy: '/ships/sc_destroy'
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
        }        
    }    
});

Ext.define("Shipper", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/shippers/sc_read',
            create: '/shippers/sc_create',
            update: '/shippers/sc_update',
            destroy: '/shippers/sc_destroy'
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
        }        
    }    
});

Ext.define("HandlingHeader", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/handling_headers/sc_read',
            create: '/handling_headers/sc_create',
            update: '/handling_headers/sc_update',
            destroy: '/handling_headers/sc_destroy'
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
        }        
    }    
});
Ext.define("HandlingItem", { extend: "Ext.data.Model",
    fields: [],     
    proxy: {
        type: 'ajax',
		api: {
            read: '/handling_headers/hitems_sc_read',
            create: '/handling_headers/hitems_sc_create',
            update: '/handling_headers/hitems_sc_update',
            destroy: '/handling_headers/hitems_sc_destroy'
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
        }        
    }    
});