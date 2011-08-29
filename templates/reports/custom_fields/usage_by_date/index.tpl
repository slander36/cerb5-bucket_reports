<ul class="submenu">
</ul>
<div style="clear:both;"></div>

<h2>{$translate->_('reports.ui.custom_fields.usage_by_date')}</h2>

<form action="{devblocks_url}c=reports&report=report.custom_fields.custom_field_usage_by_date{/devblocks_url}" method="POST" id="frmRange" name="frmRange" style="margin-bottom:10px;">
<input type="hidden" name="c" value="reports">

<b>{$translate->_('reports.ui.date_from')}</b> <input type="text" name="start" id="start" size="24" value="{$start}"><button type="button" onclick="devblocksAjaxDateChooser('#start','#divCal');">&nbsp;<span class="cerb-sprite sprite-calendar"></span>&nbsp;</button>

<b>{$translate->_('reports.ui.date_to')}</b> <input type="text" name="end" id="end" size="24" value="{$end}"><button type="button" onclick="devblocksAjaxDateChooser('#end','#divCal');">&nbsp;<span class="cerb-sprite sprite-calendar"></span>&nbsp;</button>

<b>Grouping:</b> <select name="report_date_grouping">
	<option value="">--auto--</option>
	<option value="year" {if 'year'==$report_date_grouping}selected="selected"{/if}>Years</option>
	<option value="month" {if 'month'==$report_date_grouping}selected="selected"{/if}Months</options>
	<option value="day" {if 'day'==$report_date_gropuing}selected="selected"{/if}Days</options>
</select>

<div id="divCal"></div>

<b>{$translate->_('reports.ui.date_past')}</b> <a href="javascript:;" onclick="$('#start').val('-1 year');$('#end').val('now');">{$translate->_('reports.ui.filters.1_year')|lower}</a>
| <a href="javascript:;" onclick="$('#start').val('-6 months');$('#end').val('now');">{'reports.ui.filters.n_months'|devblocks_translate:6}</a>
| <a href="javascript:;" onclick="$('#start').val('-3 months');$('#end').val('now');">{'reports.ui.filters.n_months'|devblocks_translate:3}</a>
| <a href="javascript:;" onclick="$('#start').val('-1 month');$('#end').val('now');">{$translate->_('reports.ui.filters.1_month')|lower}</a>
| <a href="javascript:;" onclick="$('#start').val('-1 week');$('#end').val('now');">{$translate->_('reports.ui.filters.1_week')|lower}</a>
| <a href="javascript:;" onclick="$('#start').val('-1 day');$('#end').val('now');">{$translate->_('reports.ui.filters.1_day')|lower}</a>
| <a href="javascript:;" onclick="$('#start').val('today');$('#end').val('now');">{$translate->_('common.today')|lower}</a>
<br>
{if !empty($years)}
	{foreach from=$years item=year name=years}
		{if !$smarty.foreach.years.first} | {/if}<a href="javascript:;" onclick="$('#start').val('Jan 1 {$year}');$('#end').val('Dec 31 {$year} 23:59:59');">{$year}</a>
	{/foreach}
	<br>
{/if}

<select name="field_id" onchange="this.form.btnSubmit.click();">
	{foreach from=$context_manifests item=mft}
		{foreach from=$custom_fields item=f key=field_idx}
			{if 'T' != $f->type && 0==strcasecmp($mft->id,$f->context)}{* Ignore clobs *}
			<option value="{$field_idx}" {if $field_id==$field_idx}selected="selected"{/if}>{$mft->name}:{$f->name}</option>
			{/if}
		{/foreach}
	{/foreach}
</select>

<button type="submit" id="btnSubmit">{$translate->_('reports.common.run_report')|capitalize}</button>
<div id="divCal" style="display:none;position:absolute;z-index:1;"></div>
</form>

<!-- Chart -->

{if !empty($data)}

<!--[if IE]><script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/excanvas.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script><![endif]-->
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/jquery.jqplot.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.barRenderer.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.categoryAxisRenderer.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.pointLabels.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<link rel="stylesheet" type="text/css" href="{devblocks_url}c=resource&plugin=gamesalad.reports&f=css/jqplot/jquery.jqplot.min.css{/devblocks_url}?v={$smarty.const.APP_BUILD}" />

<div id="reportChart" style="width:98%;height:{25+(32*{count($data)})};"></div>

<style type="text/css">
	.jqplot-yaxis-tick {
		white-space:nowrap;	
	}
</style>

<script type="text/javascript">

{foreach from=$data item=plots key=field_name}
	line{$field_name} = [
		{foreach from=$plots key=plot item=freq name=plots}
			{$freq}{if !$smarty.foreach.plots.last},{/if}
		{/foreach}
	];
{/foreach}

chartData = [
	{foreach from=$data item=field key=field_name name=fields}
		line{$field_name}{if !$smarty.foreach.fields.last},{/if}
	{/foreach}
];


var cerbChartStyle = {
	seriesColors: [
		'rgba(115,168,0,0.8)',
		'rgba(207,218,30,0.8)',
		'rgba(249,190,49,0.8)',
		'rgba(244,89,9,0.8)',
		'rgba(238,24,49,0.8)',
		'rgba(189,19,79,0.8)',
		'rgba(50,37,238,0.8)',
		'rgba(87,109,243,0.8)',
		'rgba(116,87,229,0.8)',
		'rgba(143,46,137,0.8)',
		'rgba(241,124,242,0.8)',
		'rgba(180,117,198,0.8)',
		'rgba(196,191,210,0.8)',
		'rgba(18,134,49,0.8)',
		'rgba(44,187,105,0.8)',
		'rgba(184,197,146,0.8)',
		'rgba(46,124,180,0.8)',
		'rgba(84,189,199,0.8)',
		'rgba(24,200,252,0.8)',
		'rgba(254,194,153,0.8)',
		'rgba(213,153,160,0.8)',
		'rgba(244,237,86,0.8)',
		'rgba(204,137,59,0.8)',
		'rgba(157,88,44,0.8)',
		'rgba(108,46,45,0.8)'
	]
};

chartOptions = {
    stackSeries: true,
	legend:{ 
		show:false
	},
	title:{
		show: false 
	},
	grid:{
		shadow: false,
		background:'rgb(255,255,255)',
		borderWidth:0
	},
	seriesColors: cerbChartStyle.seriesColors,	
    seriesDefaults:{
		renderer:$.jqplot.BarRenderer,
        rendererOptions:{ 
			highlightMouseOver: true,
			barPadding:0,
			barMargin:0
		},
		shadow: false,
		fill:true,
		fillAndStroke:false,
		showLine:true,
		showMarker:false,
		markerOptions: {
			size:8,
			style:'filledCircle',
			shadow:false
		}
	},
    series:[
		{foreach from=$data item=field key=field_name name=fields}
			{ label:'{$field_name}' }{if !$smarty.foreach.fields.last},{/if}
		{/foreach}
    ],
    axes:{
        xaxis:{
		  renderer:$.jqplot.CategoryAxisRenderer,
	      tickRenderer: $.jqplot.CanvasAxisTickRenderer,
	      tickOptions: {
		  	{if count($xaxis_ticks) > 94}show:false,{/if}
		  	showGridline:false,
	        {if count($xaxis_ticks) < 94 && count($xaxis_ticks) > 13}
			angle: 90,
			{/if}
	        fontSize: '8pt'
	      },
		  ticks:['{implode("','",$xaxis_ticks) nofilter}']
		}, 
        yaxis:{
		  min:0,
		  autoscale:true,
		  tickRenderer: $.jqplot.CanvasAxisTickRenderer,
		  tickOptions:{
		  	formatString:'%d',
			fontSize: '8pt'
		  }
		}
    }
}

$('#reportChart').bind('jqplotPostDraw',function(event, plot) {
	$legend = $('#reportLegend');
	$legend.html('');
	len = plot.series.length;
	for(series in plot.series) {
		if(navigator.appName == 'Microsoft Internet Explorer') {
			$cell = $('<span style="margin-right:5px;display:inline-block;"><span style="background-color:'+plot.series[series].color.replace('rgba','rgb').replace(',0.8','')+';display:inline-block;padding:0px;margin:2px;width:16px;height:16px;">&nbsp;</span>'+plot.series[series].label+'</span>');
		} else {
			$cell = $('<span style="margin-right:5px;display:inline-block;"><span style="background-color:'+plot.series[series].color+';display:inline-block;padding:0px;margin:2px;width:16px;height:16px;">&nbsp;</span>'+plot.series[series].label+'</span>');
		}
		$legend.append($cell);
	}
});

var reportTooltip = $('#reportChart').qtip({
	show: {
		when:{ event:'jqplotDataHighlight' }
	},
	hide:{
		when:{ event:'jqplotDataUnhighlight' }
	},
	style:{
		name:'cream',
		tip:{ corner:'bottomLeft' },
		border:{
			radius:3,
			width:5
		}
	},
	position:{
		target:'mouse',
		corner:{
			tooltip:'bottomLeft',
			target:'topMiddle'
		},
		adjust:{
			x:-5
		}
	}
});

$('#reportChart').bind('jqplotDataHighlight',function(event, seriesIndex, pointIndex, data) {
	tooltip = $('#reportChart').qtip("api");
	
	str = "";
	
	if(!plot1 || !plot1.series || !plot1.series[seriesIndex])
		return;
	
	if(plot1.series[seriesIndex].label)
		str += plot1.series[seriesIndex].label;
	
	if(plot1.axes.xaxis.ticks[pointIndex])
		str += "<br>(" + plot1.axes.xaxis.ticks[pointIndex] + ")";
	
	tooltip.updateContent(str, true);
});

plot1 = $.jqplot('reportChart', chartData, chartOptions);	
</script>

{include file="devblocks:cerberusweb.reports::reports/_shared/chart_selector.tpl"}
{/if}

<br>

<!-- Table -->

{if $invalidDate}<div><font color="red"><b>{$translate->_('reports.ui.invalid_date')}</b></font></div>{/if}

{if !empty($view)}
	<div id="view{$view->id}">{$view->render()}</div>
	<br>
{/if}

{if !empty($data)}
	{foreach from=$data key=field_name item=plot name=plots}
		<div class="block" style="display:inline-block;">
		{$sum = 0}
		<h2>{$field_name}</h2>
		{foreach from=$plot key=date item=hits name=dates}
			{$date}: {$hits}<br/>
			{$sum = $sum + $hits}
		{/foreach}
		<b>Sum: {$sum}</b><br>
		<b>Mean: {($sum/count($plots))|string_format:"%0.2f"}</b><br>
		</div>
	{/foreach}
{else}
<div><b>No data.</b></div>
{/if}