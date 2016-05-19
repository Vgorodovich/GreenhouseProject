{* Smarty *}

<script type="text/javascript" src="js/controller_view.js"></script>

<script type='text/javascript'>
//-----------------------------------------------------------------------------------------------------
// наш контроллер
var controller = new Controller({$selected_controller.controller_id},'{$selected_controller.controller_name}','{$selected_controller.controller_address}');
// представление
var view = new View(controller);
{literal}
//-----------------------------------------------------------------------------------------------------
var lastSelectedMenuItem = null; // последний выбранный пункт меню
var lastVisibleContent = null; // последний видимый контент
var tempAndMotorDataRequested = false; // флаг, что мы запросили настройки температур и моторов
//-----------------------------------------------------------------------------------------------------
// обрабатываем запрос на редактирование имени
view.OnEditSensorName = function(mnemonic, sensor, row)
{
 $("#edit_sensor_name").val(mnemonic ? mnemonic.DisplayName : ""); 
  
  $("#sensor_name_dialog").dialog({modal:true, buttons: [{text: "Изменить", click: function(){
  
    var new_sensor_name = $("#edit_sensor_name").val();
    
    if(new_sensor_name != '')
    {
    
        if(!mnemonic)
        {
          // добавить
          mnemonic = new SensorMnemonicName(sensor.Index,sensor.ModuleName,"");
          controller.SensorsNames.Add(mnemonic);
          mnemonic.setName(new_sensor_name);
        }
        else
        {
          // обновить
          mnemonic.setName(new_sensor_name);
        }  
        
        // обновляем строку в таблице
        row.children('#index').html(new_sensor_name);  
    }
    
    $(this).dialog("close");

  
  } }
  
  , {text: "Отмена", click: function(){$(this).dialog("close");} }
  ] });   
  
  
}
//-----------------------------------------------------------------------------------------------------
var lastIsOnline = controller.IsOnline();
// обработчик онлайн-статуса контроллера
controller.OnStatus = function(obj)
{
  var is_online = controller.IsOnline();
  
  if(!lastIsOnline && is_online)
  {
    controller.querySensorNames(); // запрашиваем список имён датчиков из БД
    controller.queryModules(); // запрашиваем модули у контроллера
  }
  
  lastIsOnline = is_online; 
  
  if(is_online)
  {
    if(!tempAndMotorDataRequested)
    {
      tempAndMotorDataRequested = true;
      controller.queryMotorInterval();
      controller.queryTemperatureSettings();
    }
  
    $('#offline_block').hide();
    $('#online_block').show();
  }
  else
  {
    tempAndMotorDataRequested = false;
    tempAndMotorSettingsCounter = 0;
    
    $('#offline_block').show();
    $('#online_block').hide();
  }
};
//-----------------------------------------------------------------------------------------------------
// ждём получения настроек температур и моторов и только тогла показываем ссылку.
// поскольку это две разные команды - надо дождаться результата отработки обеих.
var tempAndMotorSettingsCounter = 0;
function waitForTempAndMotorData(obj)
{
  tempAndMotorSettingsCounter++;
  if(tempAndMotorSettingsCounter > 1)
  {
     $('#temp_motors_settings').show();
  }
}
//-----------------------------------------------------------------------------------------------------
// событие "Получен интервал работы моторов"
controller.OnQueryMotorWorkInterval = waitForTempAndMotorData;
// событие "Получены настройки температур"
controller.OnQueryTemperatureSettings = waitForTempAndMotorData;
//-----------------------------------------------------------------------------------------------------
// событие "Получен список модулей в прошивке"
controller.OnGetModulesList = function(obj)
{
  
};
//-----------------------------------------------------------------------------------------------------
// событие "Получен и разобран слепок состояния контроллера", приходит после вызова controller.queryState()
controller.OnUpdate = function(obj, answer)
{
  if(answer.IsOK)
  {
  
    // обновляем статус надписей и кнопок для окон, полива и досветки
    updateWindowsState();
    updateWaterState();
    updateLightState();
      
  
    $('#STATUS_MENU').show();
    
    if(controller.TemperatureList.List.length > 0)
    {
      $('#TEMPERATURE_MENU').show();
      view.fillTemperatureList('#TEMPERATURE_LIST'); // заполняем список показаний температур
    }
    else
      $('#TEMPERATURE_MENU').hide();
    
    if(controller.HumidityList.List.length > 0)
    {
      view.fillHumidityList('#HUMIDITY_LIST'); // заполняем список показаний влажности
      $('#HUMIDITY_MENU').show();
    }
    else
      $('#HUMIDITY_MENU').hide();
    
    if(controller.LuminosityList.List.length > 0)
    {
      view.fillLuminosityList('#LUMINOSITY_LIST'); // заполняем список показаний освещенности
      $('#LIGHT_MENU').show();
    }
    else
      $('#LIGHT_MENU').hide();

    if(controller.SoilMoistureList.List.length > 0)
    {
      view.fillSoilMoistureList('#SOIL_LIST'); // заполняем список показаний датчиков влажности почвы
      $('#SOIL_MENU').show();
    }
    else
      $('#SOIL_MENU').hide();


    if(controller.Modules.includes('FLOW'))
    {
      $('#flow_instant').html(controller.FlowInstantLitres);
      $('#flow_incremental').html(controller.FlowIncrementalLitres);
      
      $('#FLOW_MENU').show();
    }
    else
      $('#FLOW_MENU').hide();  


  } // is ok
};
//-----------------------------------------------------------------------------------------------------
function updateWindowsState()
{
    $('#window_state').html( controller.IsWindowsOpen ? $('#window_state_on').html() : $('#window_state_off').html());
    $('#window_mode').html( controller.IsWindowsAutoMode ? $('#mode_auto').html() : $('#mode_manual').html());
    $('#toggler_windows_mode').val( !controller.IsWindowsAutoMode ? $('#mode_auto_switch').html() : $('#mode_manual_switch').html());
    $('#toggler_windows').val(controller.IsWindowsOpen ? $('#toggle_close').html() : $('#toggle_open').html());
}
//-----------------------------------------------------------------------------------------------------
function updateWaterState()
{
    $('#water_state').html( controller.IsWaterOn ? $('#water_state_on').html() : $('#water_state_off').html());
    $('#water_mode').html( controller.IsWaterAutoMode ? $('#mode_auto').html() : $('#mode_manual').html());
    $('#toggler_water_mode').val( !controller.IsWaterAutoMode ? $('#mode_auto_switch').html() : $('#mode_manual_switch').html());
    $('#toggler_water').val(controller.IsWaterOn ? $('#toggle_off').html() : $('#toggle_on').html());

}
//-----------------------------------------------------------------------------------------------------
function updateLightState()
{
    $('#light_state').html( controller.IsLightOn ? $('#light_state_on').html() : $('#light_state_off').html());
    $('#light_mode').html( controller.IsLightAutoMode ? $('#mode_auto').html() : $('#mode_manual').html());
    $('#toggler_light_mode').val( !controller.IsLightAutoMode ? $('#mode_auto_switch').html() : $('#mode_manual_switch').html());
    $('#toggler_light').val(controller.IsLightOn ? $('#toggle_off').html() : $('#toggle_on').html());
}
//-----------------------------------------------------------------------------------------------------
// обновляем данные с контроллера
function updateControllerData()
{
  controller.queryState();
}
//-----------------------------------------------------------------------------------------------------
$(document).ready(function(){

lastVisibleContent = $('#welcome');

controller.querySensorNames(); // запрашиваем список имён датчиков из БД
controller.queryModules(); // запрашиваем модули у контроллера

updateControllerData();
window.setInterval(updateControllerData,5000); // повторяем опрос состояния каждые 5 секунд

});
//-----------------------------------------------------------------------------------------------------
// показываем тот или иной контент по клику на пункт меню
function content(elem)
{
  var jElem = $(elem);
  var eId = jElem.attr("id");
  
  if(lastSelectedMenuItem != null)
  {
    lastSelectedMenuItem.removeClass("menuitem_selected");
  }
  
  if(lastVisibleContent != null)
      lastVisibleContent.hide();
    
  var contentItem = $("#" + eId + "_CONTENT");
  contentItem.show();
  
  lastSelectedMenuItem = jElem;
  lastSelectedMenuItem.addClass("menuitem_selected");
  
  lastVisibleContent = contentItem;
  
}
//-----------------------------------------------------------------------------------------------------
// редактируем настройки температур и времени открытия моторов
function editTempSettings()
{
  
  $("#edit_t_open").val(controller.OpenTemperature); 
  $("#edit_t_close").val(controller.CloseTemperature); 
  $("#edit_motor_time").val(parseInt(controller.MotorWorkInterval/1000)); 
  
  $("#temp_settings_dialog").dialog({modal:true, buttons: [{text: "Изменить", click: function(){
  
    var openTemp = $("#edit_t_open").val();
    var closeTemp =  $("#edit_t_close").val();
    var motorWorkInterval =  parseInt($("#edit_motor_time").val());
    
    controller.saveTemperatureSettings(openTemp,closeTemp);
    controller.saveMotorInterval(motorWorkInterval);
    
    $(this).dialog("close");

  
  } }
  
  , {text: "Отмена", click: function(){$(this).dialog("close");} }
  ] });   

  
}
//-----------------------------------------------------------------------------------------------------
</script>
{/literal}