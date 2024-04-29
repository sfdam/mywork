({
  configureSelectedProducts: function (component) {
    let selectedProducts = component.get("v.selectedProducts");
    let items = JSON.parse(JSON.stringify(selectedProducts));
    items.forEach((i) => {
      i.isClickable = false;
      i.isSelected = true;
      i.isActive = false;
      i.isRemovable = false;
      i.title = i.nome;
      i.subtitle = this.getLineSubtitle(component, i);
      i.icon = i.icona;
    });

    //SM - TEN: Aggiunta condizione per non mostrare linee tecniche corporate
    items = items.filter((l) => {
      return (
        l.codice != "FIDOSBF" &&
        l.codice != "ContoAnticipiPTF" &&
        l.codice != "FidoAnticipoFatture"
      );
    });
    component.set("v.items", items);
  }
});