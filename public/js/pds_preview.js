/**
 * PDS Preview PDF Generation
 * Handles direct PDF generation and download functionality with improved quality
 */

/**
 * Generate and download PDF directly with MAXIMUM QUALITY
 */
async function downloadPDF() {
    try {
        // Check if required libraries are loaded
        if (typeof html2canvas === 'undefined') {
            throw new Error('html2canvas library is not loaded. Please refresh the page and try again.');
        }

        // Show loading state
        const downloadBtn = document.querySelector('.btn-download');
        const originalText = downloadBtn ? downloadBtn.innerHTML : '';
        if (downloadBtn) {
            downloadBtn.disabled = true;
            downloadBtn.innerHTML = '⏳ Generating High-Quality PDF...';
        }

        // Get both pages
        const page1 = document.querySelector('.page-1');
        const page2 = document.querySelector('.page-2');
        
        if (!page1 || !page2) {
            throw new Error('Pages not found. Please refresh the page and try again.');
        }

        console.log('Pages found, extracting student name...');

        // Get student name for filename
        let studentName = 'Student';
        try {
            const formRows = page1.querySelectorAll('.form-row');
            let lastName = '';
            let firstName = '';
            
            formRows.forEach(row => {
                const labels = row.querySelectorAll('label');
                labels.forEach(label => {
                    const labelText = label.textContent.trim();
                    const fieldValue = row.querySelector('.field-value');
                    if (fieldValue) {
                        if (labelText.includes('Last Name')) {
                            lastName = fieldValue.textContent.trim();
                        } else if (labelText.includes('First Name')) {
                            firstName = fieldValue.textContent.trim();
                        }
                    }
                });
            });
            
            if (lastName || firstName) {
                studentName = (lastName + '_' + firstName).trim().replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '') || 'Student';
            }
        } catch (e) {
            console.warn('Could not extract student name for filename:', e);
        }

        console.log('Student name:', studentName);

        // Wait for all images to load
        const waitForImages = async (container) => {
            const images = container.querySelectorAll('img');
            const promises = Array.from(images).map(img => {
                if (img.complete && img.naturalHeight !== 0) {
                    return Promise.resolve();
                }
                return new Promise((resolve) => {
                    const timeout = setTimeout(() => {
                        console.warn('Image load timeout:', img.src);
                        resolve();
                    }, 10000); // Increased timeout
                    
                    img.onload = () => {
                        clearTimeout(timeout);
                        resolve();
                    };
                    img.onerror = () => {
                        clearTimeout(timeout);
                        console.warn('Image failed to load:', img.src);
                        resolve();
                    };
                });
            });
            await Promise.all(promises);
        };

        console.log('Waiting for images to load...');
        await waitForImages(page1);
        await waitForImages(page2);
        await new Promise(resolve => setTimeout(resolve, 1000)); // Extra wait for rendering

        console.log('Images loaded, generating Page 1 canvas with HIGH QUALITY...');

        // IMPROVED: Generate canvas for page 1 with MAXIMUM QUALITY
        const canvas1 = await html2canvas(page1, {
            scale: 3, // INCREASED from 2 to 3 for higher quality
            useCORS: true,
            allowTaint: false,
            logging: false,
            letterRendering: true,
            backgroundColor: '#ffffff',
            imageTimeout: 15000,
            removeContainer: false,
            foreignObjectRendering: false, // More reliable rendering
            ignoreElements: (element) => {
                return element.classList.contains('print-controls') || 
                       element.tagName === 'IFRAME' ||
                       element.tagName === 'SCRIPT';
            },
            onclone: (clonedDoc) => {
                const clonedPage1 = clonedDoc.querySelector('.page-1');
                if (clonedPage1) {
                    const printControls = clonedPage1.querySelector('.print-controls');
                    if (printControls) {
                        printControls.remove();
                    }
                    
                    const footer = clonedPage1.querySelector('.page-footer');
                    if (footer) {
                        footer.style.position = 'absolute';
                        footer.style.bottom = '20px';
                        footer.style.left = '40px';
                        footer.style.right = '40px';
                    }
                    
                    // Ensure fonts are fully loaded
                    const allText = clonedPage1.querySelectorAll('*');
                    allText.forEach(el => {
                        const style = window.getComputedStyle(el);
                        el.style.fontFamily = style.fontFamily;
                        el.style.fontSize = style.fontSize;
                    });
                }
            }
        });

        console.log('Page 1 canvas generated, generating Page 2 canvas with HIGH QUALITY...');

        // IMPROVED: Generate canvas for page 2 with MAXIMUM QUALITY
        const canvas2 = await html2canvas(page2, {
            scale: 3, // INCREASED from 2 to 3 for higher quality
            useCORS: true,
            allowTaint: false,
            logging: false,
            letterRendering: true,
            backgroundColor: '#ffffff',
            imageTimeout: 15000,
            removeContainer: false,
            foreignObjectRendering: false,
            ignoreElements: (element) => {
                return element.classList.contains('print-controls') || 
                       element.tagName === 'IFRAME' ||
                       element.tagName === 'SCRIPT';
            },
            onclone: (clonedDoc) => {
                const clonedPage2 = clonedDoc.querySelector('.page-2');
                if (clonedPage2) {
                    const printControls = clonedPage2.querySelector('.print-controls');
                    if (printControls) {
                        printControls.remove();
                    }
                    
                    const footer = clonedPage2.querySelector('.page-footer');
                    if (footer) {
                        footer.style.position = 'absolute';
                        footer.style.bottom = '20px';
                        footer.style.left = '40px';
                        footer.style.right = '40px';
                    }
                    
                    // Ensure fonts are fully loaded
                    const allText = clonedPage2.querySelectorAll('*');
                    allText.forEach(el => {
                        const style = window.getComputedStyle(el);
                        el.style.fontFamily = style.fontFamily;
                        el.style.fontSize = style.fontSize;
                    });
                }
            }
        });

        console.log('Page 2 canvas generated, converting to high-quality images...');

        // IMPROVED: Convert canvases to PNG for better quality, then compress slightly
        const imgData1 = canvas1.toDataURL('image/png', 1.0);
        const imgData2 = canvas2.toDataURL('image/png', 1.0);

        console.log('Creating PDF document with optimal settings...');

        // Access jsPDF
        let jsPDF;
        if (window.jspdf && window.jspdf.jsPDF) {
            jsPDF = window.jspdf.jsPDF;
        } else if (window.jsPDF) {
            jsPDF = window.jsPDF;
        } else {
            throw new Error('jsPDF library is not available. Please refresh the page and try again.');
        }

        // IMPROVED: Create PDF with higher resolution settings
        const pdf = new jsPDF({
            orientation: 'portrait',
            unit: 'px',
            format: [816, 1056],
            compress: false, // CHANGED: Disable compression for maximum quality
            precision: 16, // Higher precision
            userUnit: 1.0
        });

        console.log('Adding page 1 to PDF...');
        
        // IMPROVED: Add images with PNG format and no additional compression
        pdf.addImage(imgData1, 'PNG', 0, 0, 816, 1056, undefined, 'NONE');

        console.log('Adding page 2 to PDF...');
        
        pdf.addPage([816, 1056], 'portrait');
        pdf.addImage(imgData2, 'PNG', 0, 0, 816, 1056, undefined, 'NONE');

        console.log('Saving PDF...');

        // Save the PDF
        pdf.save(`PDS_${studentName}.pdf`);

        console.log('High-quality PDF generated successfully!');
        
        // Restore button state
        if (downloadBtn) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = originalText;
        }
        
    } catch (error) {
        console.error('Error generating PDF:', error);
        console.error('Error details:', error.stack);
        
        let errorMessage = 'Error generating PDF: ' + error.message;
        
        if (error.message.includes('library is not')) {
            errorMessage += '\n\nPlease refresh the page and try again.';
        } else if (error.message.includes('cloned iframe')) {
            errorMessage = 'Error generating PDF: Problem with page elements.\n\nPlease try again.';
        }
        
        alert(errorMessage);
        
        const downloadBtn = document.querySelector('.btn-download');
        if (downloadBtn) {
            downloadBtn.disabled = false;
            downloadBtn.innerHTML = '📥 Download as PDF';
        }
    }
}

/**
 * Library verification - Check if required libraries are loaded
 */
window.addEventListener('load', function() {
    console.log('=== Checking Required Libraries ===');

    if (typeof html2canvas !== 'undefined') {
        console.log('✓ html2canvas is loaded');
    } else {
        console.error('✗ html2canvas failed to load');
    }

    let jsPDFFound = false;
    if (window.jspdf && window.jspdf.jsPDF) {
        console.log('✓ jsPDF is loaded (window.jspdf.jsPDF)');
        jsPDFFound = true;
    } else if (window.jsPDF) {
        console.log('✓ jsPDF is loaded (window.jsPDF)');
        jsPDFFound = true;
    }

    if (!jsPDFFound) {
        console.error('✗ jsPDF failed to load');
    }

    const page1 = document.querySelector('.page-1');
    const page2 = document.querySelector('.page-2');

    if (page1 && page2) {
        console.log('✓ Both PDS pages found');
    } else {
        console.error('✗ PDS pages not found');
    }

    console.log('=== Library Check Complete ===');
});