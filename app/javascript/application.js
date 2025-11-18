
// Auto-dismiss flash messages after 5 seconds
document.addEventListener('DOMContentLoaded', function() {
	setTimeout(function() {
		var notice = document.getElementById('flash-notice');
		if (notice) { notice.style.display = 'none'; }
		var alert = document.getElementById('flash-alert');
		if (alert) { alert.style.display = 'none'; }
	}, 5000);
});
