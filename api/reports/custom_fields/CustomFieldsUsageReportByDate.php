<?php
class CHReportCustomFieldUsageByDate extends Extension_Report {
	function render() {
		$db = DevblocksPlatform::getDatabaseService();
		$tpl = DevblocksPlatform::getTemplateService();

		// Year shortcuts
		$years = array();
		$sql = "SELECT date_format(from_unixtime(created_date), '%Y') as year FROM ticket WHERE created_date > 0 AND is_deleted = 0 GROUP BY year having year <= date_format(now(), '%Y') ORDER BY year desc limit 0,10";
		$rs = $db->Execute($sql);

		while($row = mysql_fetch_assoc($rs)) {
			$years[] = intval($row['year']);
		}
		$tpl->assign('years',$years);

		mysql_free_result($rs);

		// Dates

		@$start = DevblocksPlatform::importGPC($_REQUEST['start'],'string','-30 days');
		@$end = DevblocksPlatform::importGPC($_REQUEST['end'],'string','now');
		@$age = DevblocksPlatform::importGPC($_REQUEST['age'],'string','30d');

		// use date range if specified, else use duration prior to now
		$start_time = 0;
		$end_time = 0;

		if(empty($start) && empty($end)) {
			$start = "-30 days";
			$end = "now";
			$start_time = strtotime($start);
			$end_time = strtotime($end);
		} else {
			$start_time = strtotime($start);
			$end_time = strtotime($end);
		}

		$tpl->assign('start', $start);
		$tpl->assign('end', $end);

		// Calculate the # o ticks between the dates (and the scale -- day, month, etc)
		$range = $end_time - $start_time;
		$range_days = $range/86400;
		$plots = $range/15;

		$ticks = array();

		@$report_data_grouping = DevblocksPlatform::importGPC($_REQUEST['report_date_grouping'],'string','');
		$date_group - '';
		$date_increment = '';

		// Did the user choose a specific grouping?
		switch($report_date_grouping) {
			case 'year':
				$date_group = '%Y';
				$date_increment = 'year';
				break;
			case 'month':
				$date_group = '%Y-%m';
				$date_increment = 'month';
				break;
			case 'day':
				$date_group = '%Y-%m-%d';
				$date_increment = 'day';
				break;
		}

		// Fallback to automatic grouping
		if(empty($date_group) || empty($date_increment)) {
			if($range_days > 365) {
				$date_group = '%Y';
				$date_increment = 'year';
			} elseif($range_days > 32) {
				$date_group = '%Y-%m';
				$date_increment = 'month';
			} elseif($range_days > 1) {
				$date_group = '%Y-%m-%d';
				$date_increment = 'day';
			}else {
				$date_group = '%Y-%m-%d %H';
				$date_increment = 'hour';
			}
		}

		$tpl->assign('report_date_grouping', $date_inrcrement);

		// Find unique values
		$time = strtotime(sprintf("-1 %s", $date_increment), $start_time);
		while($time < $end_time ) {
			$time = strtotime(sprintf("+1 %s", $date_increment), $time);
			if($time <= $end_time)
				$ticks[strftime($date_group, $time)] = 0;
		}
		
		// Custom Field contexts (tickets, orgs, etc.)
		$tpl->assign('context_manifests', Extension_DevblocksContext::getAll());

		// Custom Fields
		$custom_fields = DAO_CustomField::getAll();
		$tpl->assign('custom_fields', $custom_fields);
		
		// Table + Chart
		@$field_id = DevblocksPlatform::importGPC($_REQUEST['field_id'],'integer',0);
		$tpl->assign('field_id', $field_id);
		
		if(!empty($field_id) && isset($custom_fields[$field_id])) {
			$field = $custom_fields[$field_id];
			$tpl->assign('field', $field);
		
			// Table
			
			$value_counts = self::_getValueCounts($field_id,$ticks,$date_group,$start_time,$end_time);
			$tpl->assign('value_counts', $value_counts);

			// Chart
			
			$data = array();
			$iter = 0;
			if(is_array($value_counts))
				$data = $value_counts;
			
			// Sort the data in descending order (chart reverses it)
			uasort($data, array('ChReportSorters','sortDataAsc'));
			
			$tpl->assign('data', $data);
			$tpl->assign('xaxis_ticks',array_keys($ticks));
		}
		
		$tpl->display('devblocks:gamesalad.reports::reports/custom_fields/usage_by_date/index.tpl');
	}
	
	private function _getValueCounts($field_id,$ticks,$date_group,$start_time,$end_time) {
		$db = DevblocksPlatform::getDatabaseService();
		
		// Selected custom field
		if(null == ($field = DAO_CustomField::get($field_id)))
			return;

		if(null == ($table = DAO_CustomFieldValue::getValueTableName($field_id)))
			return;

		$sql = sprintf("SELECT s.field_value, ".
			"count(s.field_value) AS hits, ".
			"DATE_FORMAT(FROM_UNIXTIME(t.updated_date), '%s') as date_plot ".
			"FROM %s AS s ".
			"JOIN ticket AS t ON t.id=s.context_id ".
			"WHERE s.context = %s ".
			"AND s.field_id = %d ".
			"AND t.updated_date > %d AND t.updated_date <= %d ".
			"GROUP BY s.field_value, date_plot ",
			$date_group,
			$table,
			$db->qstr($field->context),
			$field->id,
			$start_time,
			$end_time
		);
		$rs = $db->Execute($sql);
	
		$value_counts = array();

//		echo "Date_Group: $date_group<br/>";
//		echo "Table: $table<br/>";
//		echo "Field Context: ".$field->context."<br/>";
//		echo "Start Time: $start_time<br/>";
//		echo "End Time: $end_time<br/>";
//		echo "<br/>$sql<br/><br/>";
//		echo "isset(\$rs): ".isset($rs)."<br/>";

		while($row = mysql_fetch_assoc($rs)) {
			$value = preg_replace('/\s/','',$row['field_value']);
			$hits = intval($row['hits']);
			$date_plot = $row['date_plot'];

//			echo "Value: $value<br/>";
//			echo "Hits: $hits<br/>";
//			echo "Date Plot: $date_plot<br/>";

			switch($field->type) {
				case Model_CustomField::TYPE_CHECKBOX:
					$value = !empty($value) ? 'Yes' : 'No';
					break;
				case Model_CustomField::TYPE_DATE:
					$value = gmdate("Y-m-d H:i:s", $value);
					break;
				case Model_CustomField::TYPE_WORKER:
					$workers = DAO_Worker::getAll();
					$value = (isset($workers[$value])) ? $workers[$value]->getName() : $value;
					break;
			}

			if(!isset($value_counts[$value])) {
				$value_counts[$value] = $ticks;
			}

			$value_counts[$value][$date_plot] = intval($hits);
		}
		
		mysql_free_result($rs);
		
		arsort($value_counts);
		return $value_counts;
	}
};
