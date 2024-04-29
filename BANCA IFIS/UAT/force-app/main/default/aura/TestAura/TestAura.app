<aura:application >
      <ltng:require styles="{!join(',', $Resource.VueApps + '/index.css', $Resource.SLDS + '/assets/styles/salesforce-lightning-design-system-ltng.min.css')}"/>
	<div class="tlnxt">
    <c:VueWrapper appName="EditContact"></c:VueWrapper> 
    </div>
</aura:application>