import 'package:flutter/material.dart';

import '../../theme/colors.dart';

class TneDropdown extends StatefulWidget {
  const TneDropdown({
    super.key,
    required this.isValid,
    required this.onTap,
    required this.width,
    this.height = 130,
    required this.elements,
    required this.label,
    required this.controller,
  });
  final bool isValid;
  final double width;
  final double height;
  final List<String> elements;
  final String label;
  final TextEditingController controller;
  final Function(String value) onTap;
  @override
  State<TneDropdown> createState() => _TneDropdownState();
}

class _TneDropdownState extends State<TneDropdown> {
  @override
  Widget build(BuildContext context) {
    return MenuAnchor(
      alignmentOffset: const Offset(0, 4),
      style: const MenuStyle(padding: WidgetStatePropertyAll(EdgeInsets.zero)),
      builder: (context, controller, child) => InkWell(
        onTap: () {
          if (!widget.isValid) return;
          setState(() {
            if (controller.isOpen) {
              controller.close();
              return;
            }
            controller.open();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: mediumGrey, width: 1),
            borderRadius: const BorderRadius.all(Radius.circular(10)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  widget.controller.text.isEmpty
                      ? widget.label
                      : widget.controller.text,
                  style: TextStyle(
                    color: widget.controller.text.isEmpty || !widget.isValid
                        ? mediumGrey
                        : black,
                    fontSize: 16,
                  ),
                ),
              ),
              AnimatedRotation(
                turns: controller.isOpen ? 0.5 : 0,
                duration: const Duration(milliseconds: 500),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: widget.controller.text.isEmpty || !widget.isValid
                      ? mediumGrey
                      : black,
                ),
              ),
            ],
          ),
        ),
      ),
      menuChildren: [
        Material(
          child: Container(
            alignment: Alignment.center,
            height: widget.height,
            width: widget.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
            child: ListView.builder(
              primary: false,
              itemCount: widget.elements.length,
              itemBuilder: (context, index) => MenuItemButton(
                onPressed: () async {
                  setState(() {
                    widget.controller.text = widget.elements[index];
                    widget.onTap(widget.elements[index]);
                  });
                },
                child: ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  dense: true,
                  selectedTileColor: blueGrey.withOpacity(0.1),
                  selectedColor: blueGrey,
                  selected: widget.controller.text == widget.elements[index],
                  title: Text(widget.elements[index]),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
