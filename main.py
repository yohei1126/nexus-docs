from pathlib import Path
from docling.document_converter import DocumentConverter


def convert_pdf_to_markdown(pdf_path: str, output_path: str = None) -> str:
    """
    Convert a PDF document to Markdown using docling.

    Args:
        pdf_path: Path to the PDF file
        output_path: Optional path to save the markdown file. If None, uses same name as PDF

    Returns:
        The markdown content as a string
    """
    # Initialize the converter
    converter = DocumentConverter()

    # Convert the PDF
    result = converter.convert(pdf_path)

    # Export to markdown
    markdown_content = result.document.export_to_markdown()

    # Save to file if output path is provided
    if output_path is None:
        output_path = Path(pdf_path).with_suffix('.md')

    # Create output directory if it doesn't exist
    Path(output_path).parent.mkdir(parents=True, exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(markdown_content)

    print(f"✓ Converted {pdf_path} to {output_path}")
    return markdown_content


def convert_all_pdfs(input_dir: str = ".", output_dir: str = None) -> None:
    """
    Recursively convert all PDF files from input directory to markdown.

    Args:
        input_dir: Directory to search for PDF files (default: current directory)
        output_dir: Directory to save markdown files (default: same as PDF location)
    """
    input_path = Path(input_dir)

    if not input_path.exists():
        print(f"Error: Input directory '{input_dir}' not found")
        return

    # Find all PDF files recursively
    pdf_files = list(input_path.rglob("*.pdf"))

    if not pdf_files:
        print(f"No PDF files found in '{input_dir}'")
        return

    print(f"Found {len(pdf_files)} PDF file(s) to convert\n")

    # Convert each PDF
    success_count = 0
    skipped_count = 0
    for pdf_file in pdf_files:
        try:
            if output_dir:
                # Calculate relative path to maintain directory structure
                relative_path = pdf_file.relative_to(input_path)
                output_file = Path(output_dir) / relative_path.with_suffix('.md')
            else:
                # Convert in-place (same directory as PDF)
                output_file = pdf_file.with_suffix('.md')

            # Skip if output file already exists
            if output_file.exists():
                print(f"⊘ Skipped {pdf_file} (output already exists)")
                skipped_count += 1
                continue

            convert_pdf_to_markdown(str(pdf_file), str(output_file))
            success_count += 1
        except Exception as e:
            print(f"✗ Failed to convert {pdf_file}: {e}")

    print(f"\n{'='*60}")
    print(f"Conversion complete: {success_count}/{len(pdf_files)} files converted successfully")
    if skipped_count > 0:
        print(f"Skipped {skipped_count} file(s) (already converted)")


def main():
    import sys

    # Default: convert PDFs in current directory recursively
    input_dir = sys.argv[1] if len(sys.argv) > 1 else "."
    output_dir = sys.argv[2] if len(sys.argv) > 2 else None

    convert_all_pdfs(input_dir=input_dir, output_dir=output_dir)


if __name__ == "__main__":
    main()
