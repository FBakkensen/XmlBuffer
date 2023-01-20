// Welcome to your new AL extension.
// Remember that object names and IDs should be unique across all extensions.
// AL snippets start with t*, like tpageext - give them a try and happy coding!

pageextension 50500 "CustomerListExt" extends "Customer List"
{
    actions
    {
        addlast("&Customer")
        {
            action(DownloadItemXml)
            {
                ApplicationArea = All;

                trigger OnAction()
                var
                    ItemCategory: Record "Item Category";
                    Item: Record Item;
                    XMLBuffer: Record "XML Buffer" temporary;
                    TempBlob: Codeunit "Temp Blob";
                    XmlStream: InStream;
                    Filename: Text;
                begin
                    XMLBuffer.CreateRootElement('Items');
                    XMLBuffer.AddNamespace('bcic', 'https://bcdev.tech/bc/itemcategory');
                    XMLBuffer.AddNamespace('bci', 'https://bcdev.tech/bc/item');
                    if ItemCategory.FindSet() then
                        repeat
                            XMLBuffer.AddGroupElement('bcic:ItemCategory');
                            XMLBuffer.AddAttribute(ItemCategory.FieldName(Code), ItemCategory.Code);
                            XMLBuffer.AddElement('bcic:Description', ItemCategory.Description);
                            Item.SetRange("Item Category Code", ItemCategory.Code);
                            Item.SetAutoCalcFields(Inventory);
                            if Item.FindSet() then
                                repeat
                                    XMLBuffer.AddGroupElement('bci:Item');
                                    XMLBuffer.AddAttribute('bci:No', Item."No.");
                                    XMLBuffer.AddElement('bci:Description', item.Description);
                                    XMLBuffer.AddElement('bci:Inventory', format(Item.Inventory, 0, 9));
                                    XMLBuffer.GetParent();
                                until Item.Next() = 0;
                            XMLBuffer.GetParent();
                        until ItemCategory.Next() = 0;

                    XMLBuffer.Save(TempBlob);
                    TempBlob.CreateInStream(XmlStream);
                    Filename := 'Items.xml';
                    DownloadFromStream(XmlStream, '', '', '', Filename);
                end;
            }
        }
    }
}