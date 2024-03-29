<?php
class ChReportClosedBucketTickets extends Extension_Report {
	function render() {

		$db = DevblocksPlatform::getDatabaseService();
		$tpl = DevblocksPlatform::getTemplateService();

		@$filter_group_ids = DevblocksPlatform::importGPC($_REQUEST['group_id'],'array',array());
		$tpl->assign('filter_group_ids', $filter_group_ids);
		
		@$filter_bucket_ids = DevblocksPlatform::importGPC($_REQUEST['bucket_id'],'array',array());
		$tpl->assign('filter_bucket_ids',$filter_bucket_ids);

	   	// Top Buckets
		$groups = DAO_Group::getAll();
		$buckets = DAO_Bucket::getAll();
		$tpl->assign('groups', $groups);
		$tpl->assign('categories', $buckets);
		
		// Year shortcuts
		$years = array();
		$sql = "SELECT date_format(from_unixtime(created_date),'%Y') as year FROM ticket WHERE created_date > 0 AND is_deleted = 0 AND is_closed = 1 GROUP BY year having year <= date_format(now(),'%Y') ORDER BY year desc limit 0,10";
		$rs = $db->Execute($sql);
		
		while($row = mysql_fetch_assoc($rs)) {
			$years[] = intval($row['year']);
		}
		$tpl->assign('years', $years);
		
		mysql_free_result($rs);
		
		// Dates
		
		@$start = DevblocksPlatform::importGPC($_REQUEST['start'],'string','-30 days');
		@$end = DevblocksPlatform::importGPC($_REQUEST['end'],'string','now');
		@$age = DevblocksPlatform::importGPC($_REQUEST['age'],'string','30d');
		
		// use date range if specified, else use duration prior to now
		$start_time = 0;
		$end_time = 0;
		
		if (empty($start) && empty($end)) {
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
		
		// Calculate the # of ticks between the dates (and the scale -- day, month, etc)
		$range = $end_time - $start_time;
		$range_days = $range/86400;
		$plots = $range/15;
		
		$ticks = array();

		@$report_date_grouping = DevblocksPlatform::importGPC($_REQUEST['report_date_grouping'],'string','');
		$date_group = '';
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
			} else {
				$date_group = '%Y-%m-%d %H';
				$date_increment = 'hour';
			}
		}
		
		$tpl->assign('report_date_grouping', $date_increment);
		
		// Find unique values
		$time = strtotime(sprintf("-1 %s", $date_increment), $start_time);
		while($time < $end_time) {
			$time = strtotime(sprintf("+1 %s", $date_increment), $time);
			if($time <= $end_time)
				$ticks[strftime($date_group, $time)] = 0;
		}
		
		// Table

		$defaults = new C4_AbstractViewModel();
		$defaults->id = 'report_tickets_created';
		$defaults->class_name = 'View_Ticket';
		
		if(null != ($view = C4_AbstractViewLoader::getView($defaults->id, $defaults))) {
			$view->is_ephemeral = true;
			$view->removeAllParams();

			$view->addParam(new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_UPDATED_DATE,DevblocksSearchCriteria::OPER_BETWEEN, array($start_time, $end_time)));
			$view->addParam(new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_DELETED,DevblocksSearchCriteria::OPER_EQ, 0));
			$view->addParam(new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_CLOSED,DevblocksSearchCriteria::OPER_EQ, 1));
			$view->addParam(new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_SPAM_SCORE,DevblocksSearchCriteria::OPER_LT, 0.9));
			$view->addParam(new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_SPAM_TRAINING,DevblocksSearchCriteria::OPER_NEQ, 'S'));
			
			if(!empty($filter_group_ids)) {
				$view->addParam(new DevblocksSearchCriteria(SearchFields_Ticket::TICKET_TEAM_ID,DevblocksSearchCriteria::OPER_IN, $filter_group_ids));
			}
			
			$view->renderPage = 0;
			$view->renderSortBy = SearchFields_Ticket::TICKET_UPDATED_DATE;
			$view->renderSortAsc = false;
			
			C4_AbstractViewLoader::setView($view->id, $view);
			
			$tpl->assign('view', $view);
		}		
		
		// Chart

		$filter_ids = array();

		if(is_array($filter_bucket_ids) && !empty($filter_bucket_ids)) {
			array_push($filter_ids,sprintf("t.category_id IN (%s)",implode(',',$filter_bucket_ids)));
		}
		if(is_array($filter_group_ids) && !empty($filter_group_ids)) {
			array_push($filter_ids,sprintf("(t.category_id = 0 AND t.team_id IN (%s))", implode(',',$filter_group_ids)));
		}

		$sql = sprintf("SELECT t.team_id as group_id, " .
			"t.category_id as bucket_id, " .
			"DATE_FORMAT(FROM_UNIXTIME(t.updated_date),'%s') as date_plot, ".
			"count(*) AS hits ".
			"FROM ticket t ".
			"WHERE t.updated_date > %d AND t.updated_date <= %d ".
			"%s ".
			"AND t.is_deleted = 0 ".
			"AND t.is_closed = 1 ".
			"AND t.spam_score < 0.9000 ".
			"AND t.spam_training != 'S' ".
			"GROUP BY bucket_id, date_plot ",
			$date_group,
			$start_time,
			$end_time,
			(is_array($filter_ids) && !empty($filter_ids) ? sprintf(" AND (%s)",implode('OR',$filter_ids)) : "")
		);

		$rs = $db->Execute($sql);
		
		$data = array();
		while($row = mysql_fetch_assoc($rs)) {
			$group_id = intval($row['group_id']);
			$bucket_id = intval($row['bucket_id']);
			$date_plot = $row['date_plot'];

			if(!isset($data[$group_id]))
				$data[$group_id] = array();

			if(!isset($data[$group_id][$bucket_id]))
				$data[$group_id][$bucket_id] = $ticks;
			
			$data[$group_id][$bucket_id][$date_plot] = intval($row['hits']);

		}
		
		// Sort the data in descending order
		uasort($data, array('ChReportSorters','sortDataDesc'));
		$tpl->assign('xaxis_ticks', array_keys($ticks));
		$tpl->assign('data', $data);
		
		mysql_free_result($rs);		

		// Template
		
		$tpl->display('devblocks:gamesalad.reports::reports/ticket/closed_bucket_tickets/index.tpl');
	}
};
