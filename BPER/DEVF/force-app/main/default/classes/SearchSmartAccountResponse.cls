public class SearchSmartAccountResponse {

    public class Account {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public BankServiceType_Z bankServiceType {get;set;} 
		public String ndg {get;set;} 
		public String accountCode {get;set;} 
		public String accountId {get;set;} 
		public String ibanCode {get;set;} 
		public String isInformative {get;set;} 
		public String accountAlias {get;set;} 
		public String cabCode {get;set;} 
		public String branchCode {get;set;} 
		public String id {get;set;} 
		public String cardHash {get;set;} 
		public String cardNumber {get;set;} 
		public String bankCode {get;set;} 
		public String opening {get;set;} 
		public String notes {get;set;} 
		public String onlinePost {get;set;} 
		public String prodAccount {get;set;} 
		public String prodAccountDesc {get;set;} 
		public String cardExpirationDate {get;set;} 
		public String frontendCategory {get;set;} 
		public String tolType {get;set;} 
		public String chargeable {get;set;} 
		public String mortageType {get;set;} 
		public String cardCode {get;set;} 
		public String cardOwnerCode {get;set;} 
		public String bankDesc {get;set;} 
		public String branchDesc {get;set;} 
		public String onlinePostalOwner {get;set;} 
		public String typeClient {get;set;} 
		public String aggregatedCardCode {get;set;} 
		public String portafoglio {get;set;} 
		public String cardRelations {get;set;} 
	}
	
	public class FeeValue {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String promo {get;set;} 
		public String regime {get;set;} 
		public String promoDuration {get;set;} 
		public String expireDate {get;set;} 
	}
	
	public class SearchSmartAccountExtendedResp {
		public ListCustomerDataNPV listCustomerDataNPV {get;set;} 
	}
	
	public SearchSmartAccountExtendedResp searchSmartAccountExtendedResp {get;set;} 
	
	public class AccountHB {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public BankServiceType_Z bankServiceType {get;set;} 
		public String ndg {get;set;} 
		public String accountCode {get;set;} 
		public String accountId {get;set;} 
		public String ibanCode {get;set;} 
		public String isInformative {get;set;} 
		public String accountAlias {get;set;} 
		public String cabCode {get;set;} 
		public String branchCode {get;set;} 
		public String id {get;set;} 
		public String cardHash {get;set;} 
		public String cardNumber {get;set;} 
		public String bankCode {get;set;} 
		public String opening {get;set;} 
		public String notes {get;set;} 
		public String onlinePost {get;set;} 
		public String prodAccount {get;set;} 
		public String prodAccountDesc {get;set;} 
		public String cardExpirationDate {get;set;} 
		public String frontendCategory {get;set;} 
		public String tolType {get;set;} 
		public String chargeable {get;set;} 
		public String mortageType {get;set;} 
		public String cardCode {get;set;} 
		public String cardOwnerCode {get;set;} 
		public String bankDesc {get;set;} 
		public String branchDesc {get;set;} 
		public String onlinePostalOwner {get;set;} 
		public String typeClient {get;set;} 
		public String aggregatedCardCode {get;set;} 
		public String portafoglio {get;set;} 
		public String cardRelations {get;set;} 
	}
	
	public class Cred {
		public String state {get;set;} 
		public String credType {get;set;} 
		public String value {get;set;} 
		public String credDesc {get;set;} 
		public String userId {get;set;} 
	}
	
	public class Ndg {
		public String listaAccount {get;set;} 
		public String ndgCode {get;set;} 
		public String ndgId {get;set;} 
		public String ndgType {get;set;} 
		public String bankCode {get;set;} 
		public String ndgDesc {get;set;} 
		public String branchCode {get;set;} 
		public String ndgTypeDesc {get;set;} 
	}
	
	public class BankServiceType_Z {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String bankServiceCode {get;set;} 
		public String serviceCategory {get;set;} 
		public String subCategory {get;set;} 
		public String id {get;set;} 
	}
	
	public class CredNew {
		public List<Cred> cred {get;set;} 
	}
	
	public class Ndg_Z {
		public ListaAccount listaAccount {get;set;} 
		public String ndgCode {get;set;} 
		public String ndgId {get;set;} 
		public String ndgType {get;set;} 
		public String bankCode {get;set;} 
		public String ndgDesc {get;set;} 
		public String branchCode {get;set;} 
		public String ndgTypeDesc {get;set;} 
	}
	
	public class ListaNdg {
		public List<Ndg_Z> ndg {get;set;} 
	}
	
	public class UserProfileHb {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String listaAccount {get;set;} 
		public ListaNdg listaNdg {get;set;} 
		public String listaServizioOpzionali {get;set;} 
		public String listaTipiServiziBancaApplicabili {get;set;} 
		public UserProduct userProduct {get;set;} 
		public NdgHB ndgHB {get;set;} 
		public AccountHB accountHB {get;set;} 
		public String customerStart {get;set;} 
		public String customerCode {get;set;} 
		public String profileId {get;set;} 
		public String customerName {get;set;} 
		public String taxCode {get;set;} 
		public String vvat {get;set;} 
		public String referenceEmail {get;set;} 
		public String referenceTelephoneNumber1 {get;set;} 
		public String bankCust {get;set;} 
		public String cabCode {get;set;} 
		public String cSae {get;set;} 
		public String cRae {get;set;} 
		public String branchCode {get;set;} 
		public String customerSurname {get;set;} 
		public String ndgType {get;set;} 
		public String profileIdOld {get;set;} 
		public String companyName {get;set;} 
		public String birthDate {get;set;} 
		public String recurrenceTime {get;set;} 
		public String graz {get;set;} 
		public String managment {get;set;} 
		public String invoice {get;set;} 
		public String grazDesc {get;set;} 
		public String flagTol {get;set;} 
		public String typeHB {get;set;} 
		public String riba {get;set;} 
		public String userScaState {get;set;} 
		public String scaEnrolled {get;set;} 
	}
	
	public class CustomerDataNPV {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public ClientData clientData {get;set;} 
		public Channel channel {get;set;} 
		public ListaSecEvent listaSecEvent {get;set;} 
	}
	
	public class Agent {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String agentCode {get;set;} 
		public String agentOU {get;set;} 
		public String termId {get;set;} 
		public String branch {get;set;} 
	}
	
	public class ListaAccount {
		public List<Account> account {get;set;} 
	}
	
	public class SecEvent {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String userId {get;set;} 
		public String eventType {get;set;} 
		public Agent agent {get;set;} 
		public CredNew credNew {get;set;} 
		public CredNew credOld {get;set;} 
		public String date_Z {get;set;} // in json: date
		public String note {get;set;} 
		public String channel {get;set;} 
	}
	
	public class Channel {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public FeeValue feeValue {get;set;} 
		public String channelCode {get;set;} 
		public String channelId {get;set;} 
		public String channelDesc {get;set;} 
		public String aggregationFlag {get;set;} 
		public String channelAggregationCode {get;set;} 
		public String channelDependingCode {get;set;} 
		public String channelDependingDesc {get;set;} 
	}
	
	public class ListCustomerDataNPV {
		public List<CustomerDataNPV> customerDataNPV {get;set;} 
	}
	
	public class AccountMC {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public BankServiceType bankServiceType {get;set;} 
		public String ndg {get;set;} 
		public String accountCode {get;set;} 
		public String accountId {get;set;} 
		public String ibanCode {get;set;} 
		public String isInformative {get;set;} 
		public String accountAlias {get;set;} 
		public String cabCode {get;set;} 
		public String branchCode {get;set;} 
		public String id {get;set;} 
		public String cardHash {get;set;} 
		public String cardNumber {get;set;} 
		public String bankCode {get;set;} 
		public String opening {get;set;} 
		public String notes {get;set;} 
		public String onlinePost {get;set;} 
		public String prodAccount {get;set;} 
		public String prodAccountDesc {get;set;} 
		public String cardExpirationDate {get;set;} 
		public String frontendCategory {get;set;} 
		public String tolType {get;set;} 
		public String chargeable {get;set;} 
		public String mortageType {get;set;} 
		public String cardCode {get;set;} 
		public String cardOwnerCode {get;set;} 
		public String bankDesc {get;set;} 
		public String branchDesc {get;set;} 
		public String onlinePostalOwner {get;set;} 
		public String typeClient {get;set;} 
		public String aggregatedCardCode {get;set;} 
		public String portafoglio {get;set;} 
		public String cardRelations {get;set;} 
	}
	
	public class AddressPrf {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String address {get;set;} 
		public String addressLocal {get;set;} 
		public String addressCap {get;set;} 
	}
	
	public class NdgHB {
		public String listaAccount {get;set;} 
		public String ndgCode {get;set;} 
		public String ndgId {get;set;} 
		public String ndgType {get;set;} 
		public String bankCode {get;set;} 
		public String ndgDesc {get;set;} 
		public String branchCode {get;set;} 
		public String ndgTypeDesc {get;set;} 
	}
	
	public class ListaSecEvent {
		public List<SecEvent> secEvent {get;set;} 
	}
	
	public class BankServiceType {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String bankServiceCode {get;set;} 
		public String serviceCategory {get;set;} 
		public String subCategory {get;set;} 
		public String id {get;set;} 
	}
	
	public class ClientData {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public Ndg ndg {get;set;} 
		public String account {get;set;} 
		public AccountMC accountMC {get;set;} 
		public AddressPrf addressPrf {get;set;} 
		public UserProfileHb userProfileHb {get;set;} 
		public String branchAgent {get;set;} 
		public String denomBranchCustomer {get;set;} 
		public String surname {get;set;} 
		public String name {get;set;} 
		public String taxCode {get;set;} 
		public String birthDate {get;set;} 
		public String denomination {get;set;} 
		public String vat {get;set;} 
		public String referenceMail {get;set;} 
		public String business {get;set;} 
		public String status {get;set;} 
		public String referencePhone {get;set;} 
		public String username {get;set;} 
		public String managment {get;set;} 
		public String alias {get;set;} 
		public String branchCustomer {get;set;} 
		public String overrideCode {get;set;} 
		public String flgCharge {get;set;} 
		public String ownerDenomin {get;set;} 
		public String activeServiceDesc {get;set;} 
		public String businessDesc {get;set;} 
		public String businessName {get;set;} 
		public String userIdStatus {get;set;} 
		public String passwordStatus {get;set;} 
	}
	
	public class UserProduct {
		public String valid {get;set;} 
		public String creationUser {get;set;} 
		public String lastUpdateUser {get;set;} 
		public String creationDate {get;set;} 
		public String updateDate {get;set;} 
		public String bperGenericId {get;set;} 
		public String listaAgreements {get;set;} 
		public String productCode {get;set;} 
		public String description {get;set;} 
		public String bank {get;set;} 
		public String descriptionFull {get;set;} 
		public String flagTol {get;set;}
	}

	public static SearchSmartAccountResponse parse(String json) {
		return (SearchSmartAccountResponse) System.JSON.deserialize(json, SearchSmartAccountResponse.class);
	}
}