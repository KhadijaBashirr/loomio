angular.module('loomioApp').directive 'proposalPieChart', ->
  scope: {proposal: '=', size: '='}
  restrict: 'E'
  templateUrl: 'generated/js/modules/discussion_page/proposals_card/proposal_pie_chart.html'
  replace: true
  controller: 'ProposalPieChartController'
  link: (scope, element, attrs) ->
