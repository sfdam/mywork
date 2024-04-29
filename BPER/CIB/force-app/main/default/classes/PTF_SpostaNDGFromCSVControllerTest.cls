@isTest
public class PTF_SpostaNDGFromCSVControllerTest {
	@isTest
    public static void testGetAllData() {
        PTF_SpostaNDGFromCSVController.WrapperResponse x = PTF_SpostaNDGFromCSVController.getDate('[{"ndgNumber":"1234","abi":"05387","newPTFId":"a1c9E000001gEgVQAU","newCedfiliale":"123"},{"ndgNumber":"1234","abi":"05387","newPTFId":"a1c9E000001gEgVQAU","newCedfiliale":"123"}]');
    }

}