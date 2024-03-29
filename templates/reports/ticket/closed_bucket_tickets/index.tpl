<ul class="submenu">
</ul>
<div style="clear:both;"></div>

<div class="block">
<h2>{$translate->_('reports.ui.ticket.closed_bucket_tickets')}</h2>

<form action="{devblocks_url}c=reports&report=report.tickets.closed_bucket_tickets{/devblocks_url}" method="POST" id="frmRange" name="frmRange">
<input type="hidden" name="c" value="reports">
<b>{$translate->_('reports.ui.date_from')}</b> <input type="text" name="start" id="start" size="24" value="{$start}"><button type="button" onclick="devblocksAjaxDateChooser('#start','#divCal');">&nbsp;<span class="cerb-sprite sprite-calendar"></span>&nbsp;</button>
<b>{$translate->_('reports.ui.date_to')}</b> <input type="text" name="end" id="end" size="24" value="{$end}"><button type="button" onclick="devblocksAjaxDateChooser('#end','#divCal');">&nbsp;<span class="cerb-sprite sprite-calendar"></span>&nbsp;</button>
<b>Grouping:</b> <select name="report_date_grouping">
	<option value="">-auto-</option>
	<option value="year" {if 'year'==$report_date_grouping}selected="selected"{/if}>Years</option>
	<option value="month" {if 'month'==$report_date_grouping}selected="selected"{/if}>Months</option>
	<option value="day" {if 'day'==$report_date_grouping}selected="selected"{/if}>Days</option>
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

<b>{$translate->_('reports.ui.filters.bucket')}</b> 

<div>
{foreach from=$groups item=group}
	<div style='display:inline'>
	<button id='toggle_group' value='{$group->id}'>
	Show {$group->name}
	</button>
	</div>
{/foreach}
</div>
<br/>
<div id='bucket_container'>
{foreach from=$groups item=group}
	<div style='display:none' id='{$group->id}'>
	<button id='add_group' value='{$group->id}' name='{$group->name} - Inbox'>
	<span class="cerb-sprite2 sprite-plus-circle-frame"></span>
	Add Inbox
	</button>
	{foreach from=$categories item=bucket}
		{if $bucket->team_id == $group->id}
			<button id='add_bucket' value='{$bucket->id}' name='{$group->name} - {$bucket->name}'>
			<span class="cerb-sprite2 sprite-plus-circle-frame"></span>
			Add {$bucket->name}
			</button>
		{/if}
	{/foreach}
	</div>
{/foreach}
</div>

{if (is_array($filter_bucket_ids) && !empty($filter_bucket_ids)) || (is_array($filter_group_ids) && !empty($filter_group_ids))}
	<br/>
	<div>
	<ul id="filtered_buckets" class="bubbles chooser-container">
		{foreach from=$filter_bucket_ids item=filter_bucket_id}
			{$filter_bucket = $categories[$filter_bucket_id]}
			{if !empty($filter_bucket)}
				<li>{$groups[$filter_bucket->team_id]->name} - {$filter_bucket->name}<input type="hidden" name="bucket_id[]" value="{$filter_bucket->id}"><a href="javascript:;" onclick="$(this).parent().remove();"><span class="ui-icon ui-icon-trash" style="display:inline-block;width:14px;height:14px;"></span></a></li>
			{/if}
		{/foreach}
		{foreach from=$filter_group_ids item=filter_group_id}
			{$filter_group = $groups[$filter_group_id]}
			{if !empty($filter_group)}
				<li>{$groups[$filter_group_id]->name} - Inbox<input type="hidden" name="group_id[]" value="{$filter_group->id}"><a href="javascript:;" onclick="$(this).parent().remove();"><span class="ui-icon ui-icon-trash" style="display:inline-block;width:14px;height:14px"></span></a></li>
			{/if}
		{/foreach}
	</ul>
	</div>
{/if}

<br/>

<div>
<button type="submit" id="btnSubmit">{$translate->_('reports.common.run_report')|capitalize}</button>
</div>

</form>
</div>

<!-- Chart -->

{if !empty($data)}

<!--[if IE]><script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/excanvas.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script><![endif]-->
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/jquery.jqplot.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.barRenderer.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.canvasTextRenderer.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.canvasAxisTickRenderer.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<script language="javascript" type="text/javascript" src="{devblocks_url}c=resource&plugin=gamesalad.reports&f=js/jqplot/plugins/jqplot.categoryAxisRenderer.min.js{/devblocks_url}?v={$smarty.const.APP_BUILD}"></script>
<link rel="stylesheet" type="text/css" href="{devblocks_url}c=resource&plugin=gamesalad.reports&f=css/jqplot/jquery.jqplot.min.css{/devblocks_url}?v={$smarty.const.APP_BUILD}" />

<div id="reportLegend" style="margin:5px;"></div>
<div id="reportChart" style="width:98%;height:350px;"></div>

<script type="text/javascript">
{foreach from=$data item=group key=group_id}
	{foreach from=$group item=plots key=bucket_id}
		line{$bucket_id} = [
			{foreach from=$plots key=plot item=freq name=plots}
				{$freq}{if !$smarty.foreach.plots.last},{/if}
			{/foreach}
		];
	{/foreach}
{/foreach}

chartData = [
	{foreach from=$data item=group key=group_id name=groups}
		{foreach from=$group item=null key=bucket_id name=buckets}
			line{$bucket_id}{if !$smarty.foreach.buckets.last},{/if}
		{/foreach}
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
		{foreach from=$data key=group_id item=group name=groups}
			{foreach from=$group item=bucket key=bucket_id name=buckets}
				{ label:'{$groups.$group_id->name} - {if $bucket_id == 0}Inbox{else}{$categories.$bucket_id->name}{/if}' }{if !$smarty.foreach.buckets.last},{/if}
			{/foreach}
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
	{foreach from=$data key=group_id item=groupData name=groups}
		{foreach from=$groupData key=bucket_id item=plots name=buckets}
			<div class="block" style="display:inline-block;">
			{$sum = 0}
			{if $bucket_id != 0}
				<h2>{$groups.{$group_id}->name} - {$categories.{$bucket_id}->name}</h2>
			{else}
				<h2>{$groups.{$group_id}->name} - Inbox</h2>
			{/if}
			{foreach from=$plots key=plot item=data name=plots}
				{$plot}: {$data}<br/>
				{$sum = $sum + $data}
			{/foreach}
			<b>Sum: {$sum}</b><br>
			<b>Mean: {($sum/count($plots))|string_format:"%0.2f"}</b><br>
			</div>
		{/foreach}
	{/foreach}
{else}
<div><b>No data.</b></div>
{/if}

<br>

<script type="text/javascript">
	$('#frmRange button.chooser_group').each(function(event) {
		ajax.chooser(this,'cerberusweb.contexts.group','group_id', { autocomplete:true });
	});
</script>

<script type='text/javascript'>
	$('button#toggle_group').click(function(event) {
		event.preventDefault();
		var target = $('div#'+this.value);
		var shown = (target.hasClass('shown') ? true : false);
		if($('div.shown').length > 0) {
			$('div.shown').toggle('slow',function() {
				$('div.shown').removeClass('shown');
				if(!shown) {
					target.toggle('slow');
					target.addClass('shown');
				}
			});
		} else {
			target.toggle('slow');
			target.addClass('shown');
		}
	});

	$('button#add_bucket').click(function(event) {
		event.preventDefault();
		$ul = $('ul#filtered_buckets.chooser-container');
		if(0 == $ul.length) {
			$div = $('<div></div>');
			$div.insertAfter($('div#bucket_container'));
			$ul = $('<ul id="filtered_buckets" class="bubbles chooser-container"></ul>');
			$div.append($ul);
			$('<br/>').insertAfter($('div#bucket_container'));
		}
		if(0 == $ul.find('input:hidden[value='+this.value+'][name="bucket_id[]"]').length) {
			$li = $('<li>'+$(this).attr('name')+'<input type="hidden" name="bucket_id[]" value="'+this.value+'"><a href="javascript:;" onclick="$(this).parent().remove();"><span class="ui-icon ui-icon-trash" style="display:inline-block;width:14px;height:14px;"></span></a></li>');
			$ul.append($li);
		}
	});

	$('button#add_group').click(function(event) {
		event.preventDefault();
		$ul = $('ul#filtered_buckets.chooser-container')
;		if(0 == $ul.length) {
			$div = $('<div></div>');
			$div.insertAfter($('div#bucket_container'));
			$ul = $('<ul id="filtered_buckets" class="bubbles chooser-container"></ul>');
			$div.append($ul);
			$('<br/>').insertAfter($('div#bucket_container'));
		}
		if(0 == $ul.find('input:hidden[value='+this.value+'][name="group_id[]"]').length) {
			$li = $('<li>'+$(this).attr('name')+'<input type="hidden" name="group_id[]" value="'+this.value+'"><a href="javascript:;" onclick="$(this).parent().remove();"><span class="ui-icon ui-icon-trash" style="display:inline-block;width:14px;height:14px;"></span></a></li>');
			$ul.append($li);
		}
	});
</script>
