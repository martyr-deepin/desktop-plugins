class HashMap
    constructor:->
        size = 0
        entry = new Object()

        put:(key , value)->
            if(!@containsKey(key)) then size++
            entry[key] = value
     
        get:(key)->
            if(@containsKey(key)) then return entry[key]
            else then return null
     
        remove:( key )->
            if(delete entry[key]) then size--
     
     this.containsKey = function ( key )
     {
         return (key in entry);
     }
     
     /** 是否包含 Value **/
     this.containsValue = function ( value )
     {
         for(var prop in entry)
         {
             if(entry[prop] == value)
             {
                 return true;
             }
         }
         return false;
     }
     
     /** 所有 Value **/
     this.values = function ()
     {
         var values = new Array(size);
         for(var prop in entry)
         {
             values.push(entry[prop]);
         }
         return values;
     }
     
     /** 所有 Key **/
     this.keys = function ()
     {
         var keys = new Array(size);
         for(var prop in entry)
         {
             keys.push(prop);
         }
         return keys;
     }
     
     /** Map Size **/
     this.size = function ()
     {
         return size;
     }
 }
 
 var map = new HashMap();
 
 /*
 map.put("A","1");
 map.put("B","2");
 map.put("A","5");
 map.put("C","3");
 map.put("A","4");
 */
 
 /*
 alert(map.containsKey("XX"));
 alert(map.size());
 alert(map.get("A"));
 alert(map.get("XX"));
 map.remove("A");
 alert(map.size());
 alert(map.get("A"));
 */
 
 /** 同时也可以把对象作为 Key **/
 /*
 var arrayKey = new Array("1","2","3","4");
 var arrayValue = new Array("A","B","C","D");
 map.put(arrayKey,arrayValue);
 var value = map.get(arrayKey);
 for(var i = 0 ; i < value.length ; i++)
 {
     //alert(value[i]);
 }
 */
 /** 把对象做为Key时 ，自动调用了该对象的 toString() 方法 其实最终还是以String对象为Key**/
 
 /** 如果是自定义对象 那自己得重写 toString() 方法 否则 . 就是下面的结果 **/
 
 function MyObject(name)
 {
     this.name = name;
 }
 
 /**
 function MyObject(name)
 {
     this.name = name;
     
     this.toString = function ()
     {
         return this.name;
     }
 }
 **/
 var object1 = new MyObject("小张");
 var object2 = new MyObject("小名");
 
 map.put(object1,"小张");
 map.put(object2,"小名");
 alert(map.get(object1));
 alert(map.get(object2));
 alert(map.size());
 
 /** 运行结果 小名 小名 size = 1 **/
 
 /** 如果改成复写toString()方法的对象 , 效果就完全不一样了 **/
 
 </script>
